# Demo Script

Find here the steps usually taken for performing this demo.

## Demo preparation

A day before the demo you need to deploy two Synapse environments, the main one for the demo and an additional one for demonstrationg the QA deployment. You can use the provided Issue that uses an action for deploying the first environment, and then you create an empty one connected to the storage that was created for the first one.

The first environment should be connected to this repo, so follow the steps to connect the workspace to the repo, set the collab branch and use `/queries` as the `Root folder`, but do not check the "Import existing resource" option:

![Configure repo](images/configure_repo.png)

## Script

1. Integrate Synapse with Git
    * Show demo already integrated
    * Show qa not integrated and explain why
    * Show git integration and switch to live mode to show you cannot publish
2. Work with git
    * Show how to create a branch from collab
    * Show juanserv_test_2 branch where some work is done
    * Start a pull request
3. Demo how to publish
    * Do a change in collab branch
    * Commit & publish
    * Show what changed
    * Show the repo and how one deployment file was created
    * Merge workspace_publish with qa
    * Show GitHub Actions
    * Show Secrets!
    * Publish into qa
4. Now that we have published we need to create more environments, we will do bicep
    * Show issues feature
    * Fill a issue and deploy
    * Show deployment how it started
    * Show action file, explain it, show bicep
    * Now go into codespace and show bicep file and Bicep visualizer:
    ![Bicep visualizer](./images/bicep_visualizer.png)