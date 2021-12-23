//
//  TasksFilterType.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 03/12/2021.
//

import Foundation

enum TasksFilterType {
      /**
       * Do not filter tasks.
       */
      case ALL_TASKS

      /**
       * Filters only the active (not completed yet) tasks.
       */
      case ACTIVE_TASKS

      /**
       * Filters only the completed tasks.
       */
      case COMPLETED_TASKS
}
