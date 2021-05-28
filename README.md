# notion-capture

This project connects to Notion's API using credentials you provide,
downloads data underneath a space you provide,
and syncs that data to a GitHub repo that you provide.
Therefore, you can use Notion freely
without the worry that your data is locked in forever.

## How it works

The syncing behavior is performed using a series of Sidekiq background jobs.
Starting with all of the top-level pages underneath a particular space in your Notion account,
the outermost job will recursively descend into these pages
and access the data for them through Notion's API.
It will create a JSON file in the GitHub for each page it finds,
mirroring the same structure by which you've organized pages in Notion.
These background jobs also capture tables and databases that you've defined.

## Usage

### Deploying the app to your Heroku account

This project is designed to run as a free app on Heroku,
so if you want to keep a copy of your own Notion data,
you will want to deploy your own version of this app.

Before you do this, however, you will need to satisfy some prequisites:

1. You will need to [create a personal access token]
   through your GitHub account.
   This will be used to push changes to your repo.
2. You will need to pre-create a GitHub repo to hold your Notion data.
   You can call it whatever you want.
3. You will need to obtain your Notion user id.
   This will be used to retrieve data under a specific space in Notion.
   Currently, the only way to get this
   is to follow these steps:
   1. Log in to and access Notion in a browser.
   2. Open up Dev Tools.
   3. Click on the Application tab.
   4. Click on Cookies in the sidebar.
   5. Click `https://www.notion.so`.
   6. Look for `notion_user_id`. Copy this value.
4. You will need to create a [Heroku] account.

[create a personal access token]: https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token
[Heroku]: https://heroku.com

Once you've done these things,
simply click the button below:

[![Deploy this app to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

This will bring you to a screen
where you can provide a name for the app.
You will also have an opportunity to fill in the following pieces of data:

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
 Your Notion user id as you copied above.
 This will be used to access your data using Notion's API.
* `SIDEKIQ_USERNAME`:
 A username to access the Sidekiq Web UI at
 <https://your-app-name.herokuapp.com/sidekiq>
 (by default, the username is "sidekiq").
* `SIDEKIQ_PASSWORD`:
 A username to access the Sidekiq Web UI at
 <https://your-app-name.herokuapp.com/sidekiq>.

Finally, once the app is successfully deployed,
visit the dashboard page for the app.
Then go to the Dynos section.
You should see the following list of dynos;
make sure they are all turned on:

* `web`
* `sidekiq`
* `clock`

Now you are ready to go.

### Accessing the job queue

As stated above,
the app will automatically sync Notion data every day
using a series of Sidekiq background jobs.
You can monitor the status of these jobs
by accessing the following URL once the app is built and running:

<https://your-app-name.herokuapp.com/sidekiq>

By default the UI is behind HTTP basic authentication.
The username and password are stored
in the `SIDEKIQ_USERNAME` and `SIDEKIQ_PASSWORD` environment variables you set above.

## Development

* Run `bin/setup` to start
* Run `bundle exec rake` to run all tests

## Future changes

The app is mostly complete,
but I still have a few more things planned for it.
Here are the outstanding items so far:

* Delete content from repo that gets deleted on Notion
* Add little API that blog repo can use to pull data

## Author/License

All code here is authored by Elliot Winkler (<elliot.winkler@gmail.com>)
and is made available under the [public domain].

[public domain]: ./LICENSE
