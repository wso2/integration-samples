// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/mcp.v2 as mcpv2;

const int SERVER_PORT = 9090;

listener mcpv2:StreamableHttpListener taskListener = new (SERVER_PORT);

// The service carries no authentication of its own: the platform secures the endpoint it is
// published on, so the same server runs unchanged whichever scheme the endpoint is given.
@mcpv2:StreamableHttpServiceConfig {
    info: {name: "task-management", version: "1.0.0"}
}
service mcpv2:StreamableHttpService /mcp on taskListener {

    # List the tasks on the board, newest last. Pass a status to see only those tasks.
    # + status - Optional status filter: open, in-progress or done
    # + return - The matching tasks
    @mcpv2:Tool
    remote isolated function listTasks(TaskStatus? status = ()) returns Task[] {
        return readBoard(status);
    }

    # Add a task to the board. It starts out open, and unassigned unless an assignee is given.
    # + title - What the task is
    # + priority - How much it matters: low, medium or high. Defaults to medium.
    # + assignee - Who the task belongs to. Left unassigned when omitted.
    # + return - The task as it was created
    @mcpv2:Tool
    remote isolated function createTask(string title, Priority priority = MEDIUM, string? assignee = ())
            returns Task|error {
        if title.trim() == "" {
            return error("A task needs a title.");
        }
        return addTask(title.trim(), priority, assignee);
    }

    # Move a task to a different status, for example to start or finish it.
    # + taskId - Id of the task, for example T-1003
    # + status - The status to move it to: open, in-progress or done
    # + return - The task as it now stands
    @mcpv2:Tool
    remote isolated function setTaskStatus(string taskId, TaskStatus status) returns Task|error {
        return setStatus(taskId, status);
    }

    # Give a task to someone, replacing whoever holds it now.
    # + taskId - Id of the task, for example T-1003
    # + assignee - Who the task should belong to
    # + return - The task as it now stands
    @mcpv2:Tool
    remote isolated function assignTask(string taskId, string assignee) returns Task|error {
        if assignee.trim() == "" {
            return error("An assignee needs a name.");
        }
        return setAssignee(taskId, assignee.trim());
    }
}
