/*
 * Copyright (C) 2018 - present Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import getCookie from '@instructure/get-cookie'
import possibleTypes from '@canvas/apollo-v3/possibleTypes.json'
import {
  ApolloClient,
  ApolloProvider,
  InMemoryCache,
  HttpLink,
  ApolloLink,
  gql,
} from '@apollo/client'
import {Query} from '@apollo/client/react/components'
import {persistCache} from 'apollo3-cache-persist'
import {onError} from '@apollo/client/link/error'

import EncryptedForage from '../encrypted-forage'

function createConsoleErrorReportLink() {
  return onError(({graphQLErrors, networkError}) => {
    if (graphQLErrors)
      graphQLErrors.map(({message, locations, path}) =>
        console.log(`[GraphQL error]: Message: ${message}, Location: ${locations}, Path: ${path}`),
      )
    if (networkError) console.log(`[Network error]: ${networkError}`)
  })
}

function setHeadersLink() {
  return new ApolloLink((operation, forward) => {
    operation.setContext({
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'GraphQL-Metrics': true,
        'X-CSRF-Token': getCookie('_csrf_token'),
      },
    })
    return forward(operation)
  })
}

function createHttpLink(httpLinkOptions = {}) {
  const defaultOptions = {
    uri: '/api/graphql',
    credentials: 'same-origin',
  }
  const linkOpts = {
    ...defaultOptions,
    ...httpLinkOptions,
  }
  return new HttpLink(linkOpts)
}

function createCache() {
  return new InMemoryCache({
    addTypename: true,
    dataIdFromObject: object => {
      let cacheKey

      if (object.id) {
        cacheKey = object.id
      } else if (object._id && object.__typename === 'RubricAssessmentRating') {
        cacheKey = object.__typename + object._id + object.rubricAssessmentId
      } else if (object.__typename === 'RubricRating') {
        cacheKey = object.__typename + object._id + object.rubricId
      } else if (object._id && object.__typename) {
        cacheKey = object.__typename + object._id
      } else {
        return null
      }

      // Multiple distinct RubricAssessments (and likely other versionable
      // objects) may be represented by the same ID and type. Add the
      // artifactAttempt field to the cache key to assessments for different
      // attempts don't collide.
      if (
        ['RubricAssessment', 'RubricAssessmentRating'].includes(object.__typename) &&
        object.artifactAttempt != null
      ) {
        cacheKey = `${cacheKey}:${object.artifactAttempt}`
      }
      return cacheKey
    },
    possibleTypes: possibleTypes,
    typePolicies: {
      Query: {
        fields: {
          node: {
            merge(existing = {}, incoming, { mergeObjects }) {
              return mergeObjects(existing, incoming);
            },
          },
        },
      },
    },
  })
}

async function createPersistentCache(passphrase = null) {
  const cache = createCache()
  await persistCache({
    cache,
    storage: new EncryptedForage(passphrase),
  })
  return cache
}

function createClient(opts = {}) {
  const cache = opts.cache || createCache()

  // there are some cases where we need to override these options.
  //  If we're using an API gateway instead of talking to canvas directly,
  // we need to be able to inject that config.
  // also if we need to test what the client is sending over the wire,
  // being able to override the "fetch" method is useful.
  // A design goal here is not to do anything "special", but just
  // use the options that are already built into ApolloLink:
  // https://github.com/apollographql/apollo-client/blob/main/src/link/core/ApolloLink.ts
  const httpLinkOptions = opts.httpLinkOptions || {}

  const links =
    createClient.mockLink == null
      ? [createConsoleErrorReportLink(), setHeadersLink(), createHttpLink(httpLinkOptions)]
      : [createConsoleErrorReportLink(), createClient.mockLink]

  const client = new ApolloClient({
    link: ApolloLink.from(links),
    cache,
  })

  return client
}

export {ApolloProvider, createClient, createCache, createPersistentCache, Query, gql}
