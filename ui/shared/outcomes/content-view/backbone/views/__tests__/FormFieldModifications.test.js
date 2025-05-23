/*
 * Copyright (C) 2025 - present Instructure, Inc.
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

import $ from 'jquery'
import 'jquery-migrate'
import Outcome from '../../../../backbone/models/Outcome'
import OutcomeContentBase from '../OutcomeContentBase'
import OutcomeView from '../OutcomeView'

// stub function that creates the RCE to avoid
// its async initialization
OutcomeContentBase.prototype.readyForm = () => {}

const waitFrames = async frames => {
  for (let i = 0; i < frames; i++) {
    await new Promise(resolve => requestAnimationFrame(resolve))
  }
}

function buildOutcome(outcomeOptions = {}, outcomeLinkOptions = {}) {
  const base = {
    context_type: 'Course',
    context_id: 1,
    outcome_group: {outcomes_url: 'blah'},
    outcome: {
      id: 1,
      title: 'Outcome1',
      description: 'outcome1 test',
      context_type: 'Course',
      context_id: 1,
      points_possible: '5',
      mastery_points: '3',
      url: 'blah',
      calculation_method: 'decaying_average',
      calculation_int: 65,
      assessed: false,
      can_edit: true,
    },
  }
  Object.assign(base.outcome, outcomeOptions)
  Object.assign(base, outcomeLinkOptions)
  return base
}

function createView(opts) {
  const application = $('<div id="application" />')
  application.appendTo($('#fixtures'))
  const view = new OutcomeView(opts)
  view.$el.appendTo(application)
  return view.render()
}

describe('OutcomeView Form Field Modifications', () => {
  let view

  beforeEach(() => {
    document.body.innerHTML = '<div id="fixtures"></div>'
  })

  afterEach(() => {
    if (view) {
      view.remove()
      view = null
    }
    document.body.innerHTML = ''
  })

  it('returns false for all fields when not modified', async () => {
    view = createView({
      model: new Outcome(buildOutcome(), {parse: true}),
      state: 'edit',
    })
    await waitFrames(10)
    view.edit($.Event())
    await waitFrames(10)
    const modified = view.getModifiedFields(view.getFormData())
    expect(modified.masteryPoints).toBeFalsy()
    expect(modified.calculationInt).toBeFalsy()
    expect(modified.calculationMethod).toBeFalsy()
  })
})
