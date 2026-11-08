import { GoogleAuth, OAuth2Client } from 'google-auth-library';

// Adapt an existing operator login without saving or exposing credentials.
export function firebaseCliGoogleAuth(cliAuth, projectId) {
  const account = cliAuth.getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) throw new Error('authentication-required');
  const client = new OAuth2Client();
  client.refreshHandler = async () => {
    const tokens = await cliAuth.getAccessToken(account.tokens.refresh_token,
      ['https://www.googleapis.com/auth/cloud-platform']);
    if (!tokens.access_token || !Number.isFinite(tokens.expires_at) || tokens.expires_at <= Date.now()) {
      throw new Error('authentication-required');
    }
    return { access_token: tokens.access_token, expiry_date: tokens.expires_at };
  };
  return new GoogleAuth({ projectId, authClient: client });
}
