/*
 * Copyright (C) 2020 - present Instructure, Inc.
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

import React from 'react'
import {CloseButton, IconButton} from '@instructure/ui-buttons'
import {Flex} from '@instructure/ui-flex'
import {IconXLine} from '@instructure/ui-icons'
import {Img} from '@instructure/ui-img'
import {Link} from '@instructure/ui-link'
import {Text} from '@instructure/ui-text'
import {TruncateText} from '@instructure/ui-truncate-text'
import sanitizeHtml from 'sanitize-html-with-tinymce'
import RichContentEditor from '@canvas/rce/RichContentEditor'
import {useScope as createI18nScope} from '@canvas/i18n'
const I18n = createI18nScope('conferences')

type WebConference = {
  id: string | number
  conference_type: string
  context_id?: string
  context_type?: string
  description?: string
  lti_settings?: {
    type?: string
    url?: string
    html?: string
    icon?: {
      url?: string
    }
  }
  title: string
  url?: string
}

type WebConferenceType = {
  name: string
  type: string
  contexts?: string[]
  lti_settings?: object
}

type ConferenceProps = {
  conference: WebConference
  conferenceType?: WebConferenceType
  removeConference?: ((value?: any) => void) | null
  removeButtonRef?: (element: Element | null) => void
}

// we use this to consolidate the import of tinymce into our environment
// (as recommended by jsx/shared/sanitizeHTML)
RichContentEditor.preloadRemoteModule()

const HtmlConference = ({
  conference,
  html,
  removeConference,
  removeButtonRef,
}: {
  conference: WebConference
  html: string
  removeConference?: ((value?: any) => void) | null
  removeButtonRef?: (element: HTMLButtonElement | null) => void
}) => {
  return (
    <Flex as="div" direction="row-reverse" wrap="wrap" alignItems="center">
      {removeConference && (
        <Flex.Item padding="none none none x-small">
          <CloseButton
            elementRef={removeButtonRef as any}
            screenReaderLabel={I18n.t('Remove conference: %{title}', {title: conference.title})}
            onClick={() => removeConference(null)}
          />
        </Flex.Item>
      )}
      <Flex.Item shouldGrow={true}>
        <div dangerouslySetInnerHTML={{__html: sanitizeHtml(html)}} />
      </Flex.Item>
    </Flex>
  )
}

const LinkConference = ({
  conference,
  conferenceType,
  removeConference,
  removeButtonRef,
}: {
  conference: WebConference
  conferenceType?: WebConferenceType
  removeConference?: ((value?: any) => void) | null
  removeButtonRef?: (element: HTMLButtonElement | null) => void
}) => {
  let url
  if (conference.lti_settings?.url) {
    url = conference.lti_settings.url
  } else if (conference.url) {
    url = `${conference.url}/join`
  }
  let title = I18n.t('%{name} Conference', {
    name: (conferenceType && conferenceType.name) || '',
  })

  if (conference.conference_type === 'LtiConference') {
    title = conference.title || I18n.t('Conference')
  }

  const iconURL = conference.lti_settings?.icon?.url
  const icon = iconURL && <Img src={iconURL} margin="0 x-small 0 0" height="20px" width="20px" />
  const text = <TruncateText>{title}</TruncateText>

  return (
    <Flex direction="row">
      <Flex.Item shouldShrink={true} shouldGrow={true}>
        <Text as="div" size="small">
          {url ? (
            <Link
              href={url}
              isWithinText={false}
              target="_blank"
              rel="noreferrer noopener"
              renderIcon={icon}
              onClick={e => e.stopPropagation()}
            >
              {text}
            </Link>
          ) : (
            text
          )}
        </Text>
      </Flex.Item>
      {removeConference && (
        <Flex.Item padding="0 0 0 x-small">
          <IconButton
            elementRef={removeButtonRef as any}
            size="small"
            withBorder={false}
            withBackground={false}
            screenReaderLabel={I18n.t('Remove conference: %{title}', {title})}
            onClick={() => removeConference()}
          >
            <IconXLine />
          </IconButton>
        </Flex.Item>
      )}
    </Flex>
  )
}

const Conference = ({
  conference,
  conferenceType,
  removeConference = null,
  removeButtonRef,
}: ConferenceProps) =>
  conference.conference_type === 'LtiConference' && conference.lti_settings?.type === 'html' ? (
    <HtmlConference
      conference={conference}
      html={conference.lti_settings!.html!}
      removeConference={removeConference}
      removeButtonRef={removeButtonRef}
    />
  ) : (
    <LinkConference
      conference={conference}
      conferenceType={conferenceType}
      removeConference={removeConference}
      removeButtonRef={removeButtonRef}
    />
  )

export default Conference
