# Swear jar

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

This is a sample app using the [bnk.dev REST API](https://documentation.bnk.dev).

The app expects an environment variable, `BANK_API_KEY`, with your [API key](https://bnk.dev/group-settings/api).

It's a swear jar. Every time you swear (and click the button) 25c is moved from your account to the swear jar. Don't have a swear jar yet? No problem! It'll also help you create one.

Yes, this is a trivial example but it shows the real world programmatic money movement.

If you'd prefer to not list your accounts and balances you can add a `BANK_ACCOUNT_ID` environment variable.
