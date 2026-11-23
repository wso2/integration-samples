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

# Where a task has got to.
public enum TaskStatus {
    OPEN = "open",
    IN_PROGRESS = "in-progress",
    DONE = "done"
}

# How much a task matters.
public enum Priority {
    LOW = "low",
    MEDIUM = "medium",
    HIGH = "high"
}

# A unit of work on the board.
public type Task record {|
    # Identifier, for example T-1003
    string id;
    # What the task is
    string title;
    # Where the task has got to
    TaskStatus status;
    # How much the task matters
    Priority priority;
    # Who the task belongs to, or () while it is unassigned
    string? assignee;
|};
