// Google OAuth2 config

export const googleOAuth2Config = {
    clientId: process.env.REACT_APP_GOOGLE_CLIENT_ID!,
    scope: 'https://www.googleapis.com/auth/admin.directory.resource.calendar.readonly https://www.googleapis.com/auth/calendar.readonly profile email',
}
