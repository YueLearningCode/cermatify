// Explicit catalog mappings: an unknown competition is reported for review.
// Never infer a category for arbitrary services or overwrite an existing link.
export const competitionCategories = [
  { id: 'desain-media-kreatif', name: 'Desain & Media Kreatif', services: ['ui/ux design', 'poster', 'desain grafis', 'infographics', 'videografi'] },
  { id: 'bisnis-kewirausahaan', name: 'Bisnis & Kewirausahaan', services: ['business case', 'business plan'] },
  { id: 'karya-tulis-penelitian', name: 'Karya Tulis & Penelitian', services: ['essai', 'esai', 'paper', 'lkti'] },
  { id: 'debat-public-speaking', name: 'Debat & Public Speaking', services: ['debate', 'speech'] },
];

const text = (doc, key) => doc.fields?.[key]?.stringValue ?? '';
const normalize = (value) => value.trim().toLowerCase().replace(/\s+/g, ' ');

export function competitionCategoryForService(name) {
  if (typeof name !== 'string' || !/\bcompetition\b/i.test(name)) return null;
  const branch = normalize(name.replace(/\bcompetition\b/ig, ''));
  return competitionCategories.find((category) => category.services.includes(branch)) ?? null;
}

export function planCompetitionCategorization({ projectId, services, categories }) {
  if (!/^[a-z][a-z0-9-]{4,62}$/.test(projectId)) throw new Error('invalid-project');
  const root = `projects/${projectId}/databases/(default)/documents`;
  const validate = (docs, collection) => {
    const names = new Set();
    for (const doc of docs) {
      if (typeof doc.name !== 'string' || !doc.name.startsWith(`${root}/${collection}/`) ||
          doc.name.slice(`${root}/${collection}/`.length).includes('/') ||
          !doc.updateTime || names.has(doc.name)) throw new Error('invalid-snapshot');
      names.add(doc.name);
    }
  };
  validate(services, 'layanan');
  validate(categories, 'competitionCategories');
  const writes = [];
  const assignments = [];
  const skipped = [];
  const categoryWrites = new Map();
  for (const service of services) {
    const name = text(service, 'name');
    if (!/\bcompetition\b/i.test(name)) continue;
    const id = service.name.split('/').at(-1);
    if (text(service, 'type') !== 'complink') {
      skipped.push({ id, name, reason: 'different-service-type' });
      continue;
    }
    if (service.fields?.competitionCategoryId && typeof service.fields.competitionCategoryId.stringValue !== 'string') {
      skipped.push({ id, name, reason: 'invalid-existing-category-field' });
      continue;
    }
    if (service.fields?.competitionCategoryId && text(service, 'competitionCategoryId') !== '') {
      skipped.push({ id, name, reason: 'already-assigned' });
      continue;
    }
    const category = competitionCategoryForService(name);
    if (!category) {
      skipped.push({ id, name, reason: 'unknown-competition' });
      continue;
    }
    // Reuse an active category with the same label before creating a stable ID.
    const existing = categories.find((doc) => normalize(text(doc, 'name')) === normalize(category.name) && doc.fields?.active?.booleanValue === true);
    const categoryName = existing?.name ?? `${root}/competitionCategories/${category.id}`;
    const collision = categories.find((doc) => doc.name === categoryName);
    if (!existing && collision) throw new Error('category-id-conflict');
    if (!categoryWrites.has(categoryName)) {
      categoryWrites.set(categoryName, existing ? {
        // Guard against a concurrent archive while linking new services.
        update: { name: categoryName, fields: { active: { booleanValue: true } } },
        updateMask: { fieldPaths: ['active'] },
        currentDocument: { updateTime: existing.updateTime },
        updateTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }],
      } : {
        update: { name: categoryName, fields: { name: { stringValue: category.name }, active: { booleanValue: true } } },
        currentDocument: { exists: false },
        updateTransforms: ['createdAt', 'updatedAt'].map((fieldPath) => ({ fieldPath, setToServerValue: 'REQUEST_TIME' })),
      });
    }
    const categoryId = categoryName.split('/').at(-1);
    writes.push({
      update: { name: service.name, fields: { competitionCategoryId: { stringValue: categoryId } } },
      updateMask: { fieldPaths: ['competitionCategoryId'] },
      currentDocument: { updateTime: service.updateTime },
    });
    assignments.push({ id, name, categoryId, categoryName: existing ? text(existing, 'name') : category.name });
  }
  return { projectId, assignments, skipped, writes: [...categoryWrites.values(), ...writes] };
}
