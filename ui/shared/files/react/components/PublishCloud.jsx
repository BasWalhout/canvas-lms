/*
 * Copyright (C) 2015 - present Instructure, Inc.
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
import createReactClass from 'create-react-class'
import ReactDOM from 'react-dom'
import $ from 'jquery'
import {useScope as createI18nScope} from '@canvas/i18n'
import PublishCloud from './LegacyPublishCloud'
import 'jqueryui/dialog'

const I18n = createI18nScope('publish_cloud')

// Function Summary
// Create a blank dialog window via jQuery, then dump the RestrictedDialogForm into that
// dialog window. This allows us to do react things inside of this all ready rendered
// jQueryUI widget
PublishCloud.openRestrictedDialog = function () {
  const buttonId = `publish-cloud-${this.props.model.id}`
  const originatorButton = $(`#${buttonId}`) ? $(`#${buttonId}`)[0] : null
  const $dialog = $('<div>').dialog({
    title: I18n.t('Editing permissions for: %{name}', {name: this.props.model.displayName()}),
    width: 800,
    minHeight: 300,
    close() {
      ReactDOM.unmountComponentAtNode(this)
      $(this).remove()
      setTimeout(() => {
        originatorButton?.focus()
      }, 0)
    },
    modal: true,
    zIndex: 1000,
  })

  import('./RestrictedDialogForm').then(({default: RestrictedDialogForm}) => {
    ReactDOM.render(
      <RestrictedDialogForm
        usageRightsRequiredForContext={this.props.usageRightsRequiredForContext}
        models={[this.props.model]}
        closeDialog={() => {
          $dialog.dialog('close')
        }}
      />,
      $dialog[0],
    )
  })
}

PublishCloud.render = function () {
  const fileName = (this.props.model && this.props.model.displayName()) || I18n.t('This file')
  if (this.props.userCanEditFilesForContext) {
    if (this.state.published && this.state.restricted) {
      return (
        <button
          id={`publish-cloud-${this.props.model.id}`}
          data-testid="restricted-button"
          type="button"
          data-tooltip="left"
          onClick={this.openRestrictedDialog}
          ref="publishCloud"
          className="btn-link published-status restricted"
          title={this.getRestrictedText()}
          aria-label={I18n.t('%{fileName} is %{restricted} - Click to modify', {
            fileName,
            restricted: this.getRestrictedText(),
          })}
          disabled={this.props.disabled}
        >
          <i className="icon-calendar-month icon-line" />
        </button>
      )
    } else if (this.state.published && this.state.hidden) {
      return (
        <button
          id={`publish-cloud-${this.props.model.id}`}
          data-testid="hidden-button"
          type="button"
          data-tooltip="left"
          onClick={this.openRestrictedDialog}
          ref="publishCloud"
          className="btn-link published-status hiddenState"
          title={I18n.t('Only available to students with link')}
          aria-label={I18n.t(
            '%{fileName} is only available to students with the link - Click to modify',
            {
              fileName,
            },
          )}
          disabled={this.props.disabled}
        >
          <i className="icon-off icon-line" />
        </button>
      )
    } else if (this.state.published) {
      return (
        <button
          id={`publish-cloud-${this.props.model.id}`}
          data-testid="published-button"
          type="button"
          data-tooltip="left"
          onClick={this.openRestrictedDialog}
          ref="publishCloud"
          className="btn-link published-status published"
          title={I18n.t('Published')}
          aria-label={I18n.t('%{fileName} is Published - Click to modify', {fileName})}
          disabled={this.props.disabled}
        >
          <i className="icon-publish icon-Solid" />
        </button>
      )
    } else {
      return (
        <button
          id={`publish-cloud-${this.props.model.id}`}
          data-testid="unpublished-button"
          type="button"
          data-tooltip="left"
          onClick={this.openRestrictedDialog}
          ref="publishCloud"
          className="btn-link published-status unpublished"
          title={I18n.t('Unpublished')}
          aria-label={I18n.t('%{fileName} is Unpublished - Click to modify', {fileName})}
          disabled={this.props.disabled}
        >
          <i className="icon-unpublish" />
        </button>
      )
    }
  } else if (this.state.published && this.state.restricted) {
    return (
      <div
        data-testid="restricted-status"
        style={{marginRight: '12px'}}
        data-tooltip="left"
        ref="publishCloud"
        className="published-status restricted"
        title={this.getRestrictedText()}
        aria-label={I18n.t('%{fileName} is %{restricted}', {
          fileName,
          restricted: this.getRestrictedText(),
        })}
        disabled={this.props.disabled}
      >
        <i className="icon-calendar-day" />
      </div>
    )
  } else {
    return <div style={{width: 28, height: 36}} />
  }
}

export default createReactClass(PublishCloud)
