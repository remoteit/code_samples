# Insomnia Collections

This folder contains Insomnia Collections of sample graphQL queries and mutations which can be imported into your Insomnia graphQL tool. Additional collections will be added from time to time as newer versions of the Remote.It graphQL API are released with newer functionality. These files will be added with a date appended to the filename to make it easier to understand newer versions. When there is a new major version released which will also mean a new url the file names will also include the version.

In general, API releases on V1 will not introduce any breaking changes only additions in functionality.
V1 Queries and mutation url https://api.remote.it/graphql/v1

## What is graphQL

GraphQL is a data query language for API's, developed by Facebook in 2012 before being publicly released in 2015. GraphQL provides an alternative to the REST API.
For more information on GraphQL, learn on the official GraphQL website [here](https://graphql.org/).

## Insomnia tool setup and authentication

[Credentials setup](https://link.remote.it/docs/credential-generation)
[Insomnia setup](https://link.remote.it/docs/insomnia)
[Import the Insomnia Collection](https://docs.insomnia.rest/insomnia/import-export-data) - Once you have downloaded the collection file you would like to work with, you can then import it into Insomnia. The Insomnia UI may change based on their releases, please refer to their documentation.

## Using the collections

Once you have setup Insomnia, you are ready to use the collection! The collection is broken down into categories of queries and mutations. These include, but are not limited to, samples of working with your device list, specific devices, connections, event logs and your account. 
Please note, permissions of authorization to fetch, update, connect, and view logs devices are based on ownership or delegated role when you do not own the device.
 
## Using graphQL in an application (not in a query tool)

[Authentication (Request Signing)](https://link.remote.it/docs/api/authentication) - You can use Insomnia to develop your queries and mutations as tests. Please note that you cannot use generated code out of Insomnia or any other query tool to port into your application or scripts. Each request is uniquely signed using elements such as the timestamp of the request and request body properties. The linked guide provides examples of the request signing portion for multiple languages.

[Usage Guidelines](https://link.remote.it/docs/api/usage/overview) - Reference page with an overview of queries, mutations and pagination. Please note, polling for state change (online/offline) is highly discouraged. Use [webhooks](https://link.remote.it/docs/webhook-content) instead.

## Contributing

See [the contributing guide](../CONTRIBUTING.md) for detailed instructions on how you can help. 

