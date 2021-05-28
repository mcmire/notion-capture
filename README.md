# notion-capture

This project connects to Notion's API using credentials you provide,
downloads data underneath a space you provide,
and syncs that data to a GitHub repo that you provide.
Therefore, you can use Notion but never worry that your data is locked in.

## Development

* Run `bin/setup` to start
* Run `bundle exec rake` to run all tests

## Usage

### Deploying the app to your Heroku account

If you want to keep a copy of your own Notion data,
make an account on [Heroku],
then deploy this app using the button below.

[Heroku]: https://heroku.com

[![Deploy this app to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Note that Heroku may attempt to build the app,
but there are requisites before this can fully complete.
Namely:

1. You will need to [create a personal access token]
   through your GitHub account.
   This will be used to push changes to your repo.
2. You will need to pre-create a repo to hold your Notion data.
   You can call it whatever you want!
3. You will need to obtain your Notion user id.
   This will be used to retrieve data under a specific space in Notion.
   Currently, the only way to get this
   is to follow these directions:
   1. Log in to and access Notion in a browser.
   2. Open up Dev Tools,
   3. Click on the Application tab.
   4. Click on Cookies in the sidebar.
   5. Click `https://www.notion.so`.
   6. Look for `notion_user_id` and copy that value.
4. Finally, after you create the app through the button above,
   you will want to set some environment variables.
   You can do this by access your app through the Heroku UI,
   then going to Settings, then "Reveal Config Vars".
  * `GITHUB_USERNAME`:
    Your GitHub username.
    This will be used to store Notion data in your repo and push it.
  * `GITHUB_ACCESS_TOKEN`:
    The personal access token you created earlier.
    This will be used to store Notion data in your repo and push it.
  * `GITHUB_REPO_NAME`:
    The name of your repo you've created
    that will ultimately hold the Notion data.
  * `NOTION_EMAIL`:
    Your Notion email address.
    This will be used to authenticate with Notion's API.
  * `NOTION_PASSWORD`:
    Your Notion password.
    This will be used to authenticate with Notion's API.
  * `NOTION_USER_ID`:
    Your Notion user id as obtained above.
    This will be used to access your data using Notion's API.
  * `SIDEKIQ_USERNAME`:
    A username to access the Sidekiq Web UI at
    <https://your-app-name.herokuapp.com/sidekiq>
    (by default, the username is "sidekiq").
  * `SIDEKIQ_PASSWORD`:
    A username to access the Sidekiq Web UI at
    <https://your-app-name.herokuapp.com/sidekiq>.

[create a personal access token]: https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token

### Accessing the job queue

The app will automatically sync Notion data every day
using a series of Sidekiq background jobs.
You can monitor the status of these jobs
by accessing the following URL once the app is built and running:

<https://your-app-name.herokuapp.com/sidekiq>

By default the UI is behind HTTP basic authentication.
The username and password are stored in `SIDEKIQ_USERNAME` and `SIDEKIQ_PASSWORD`.
