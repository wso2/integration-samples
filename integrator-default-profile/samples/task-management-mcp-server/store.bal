// Copyright (c) 2026, Choreo Labs LLC. (https://www.choreolabs.com).
//
// Choreo Labs LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

// The tasks and the id counter live in one record because a lock may reach only one
// restricted variable, and creating a task touches both.
type Board record {|
    Task[] tasks;
    int nextId;
|};

// The board lives in memory, so the sample runs with no database and no configuration.
// Every replica keeps its own copy, and a restart returns to the tasks seeded here.
isolated Board board = {
    tasks: [
        {id: "T-1001", title: "Draft the release notes", status: IN_PROGRESS, priority: HIGH, assignee: "alex"},
        {id: "T-1002", title: "Review the onboarding guide", status: OPEN, priority: MEDIUM, assignee: "priya"},
        {id: "T-1003", title: "Archive last quarter's reports", status: OPEN, priority: LOW, assignee: ()},
        {id: "T-1004", title: "Renew the staging certificate", status: DONE, priority: HIGH, assignee: "sam"}
    ],
    nextId: 1005
};

// A copy of the whole board, or of just the tasks in one status.
isolated function readBoard(TaskStatus? status) returns Task[] {
    lock {
        if status is () {
            return board.tasks.clone();
        }
        return board.tasks.filter(task => task.status == status).clone();
    }
}

// Adds a task to the board and returns it as created.
isolated function addTask(string title, Priority priority, string? assignee) returns Task {
    lock {
        Task created = {id: string `T-${board.nextId}`, title, status: OPEN, priority, assignee};
        board.nextId += 1;
        board.tasks.push(created.clone());
        return created.clone();
    }
}

// Moves the task to a status, or reports that no such task is on the board.
isolated function setStatus(string id, TaskStatus status) returns Task|error {
    lock {
        foreach Task task in board.tasks {
            if task.id == id {
                task.status = status;
                return task.clone();
            }
        }
    }
    return error(string `No task with id ${id} is on the board.`);
}

// Gives the task to someone, or reports that no such task is on the board.
isolated function setAssignee(string id, string assignee) returns Task|error {
    lock {
        foreach Task task in board.tasks {
            if task.id == id {
                task.assignee = assignee;
                return task.clone();
            }
        }
    }
    return error(string `No task with id ${id} is on the board.`);
}
