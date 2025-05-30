// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck
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

import React from 'react'
import {createRoot} from 'react-dom/client'
import type Gradebook from '../../Gradebook'
import type GridSupport from '../GridSupport'
import type {Root} from 'react-dom/client'

import TotalGradeOverrideColumnHeader from './TotalGradeOverrideColumnHeader'

function getProps(options) {
  return {
    ref: options.ref,
  }
}

export default class TotalGradeOverrideColumnHeaderRenderer {
  gradebook: Gradebook
  root: Root | null = null

  constructor(gradebook: Gradebook) {
    this.gradebook = gradebook
  }

  render(_column, $container: HTMLElement, _gridSupport: GridSupport, options) {
    const props = getProps(options)
    this.root = createRoot($container)
    this.root.render(<TotalGradeOverrideColumnHeader {...props} />)
  }

  destroy(_column, $container: HTMLElement, _gridSupport: GridSupport) {
    if (this.root) {
      this.root.unmount()
      this.root = null
    }
  }
}
