import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerinax/kafka;

public type MatchResult record {|
    string playerId;
    string displayName;
    int score;
|};

public type LeaderboardRow record {|
    string player_id;
    string display_name;
    int total_score;
    int games_played;
|};

listener kafka:Listener kafkaListener = new (bootstrapServers, {
    groupId: groupId,
    topics: [topicName]
});

service /matches on new http:Listener(8090) {
    resource function post add(MatchResult result) returns error? {
        check resultsProducer->send({topic: topicName, value: result});
        log:printInfo("Match result published", playerId = result.playerId, score = result.score);
    }
}

service kafka:Service on kafkaListener {
    remote function onConsumerRecord(MatchResult[] results) returns error? {
        foreach MatchResult result in results {
            _ = check leaderboardDb->execute(`
                INSERT INTO leaderboard (player_id, display_name, total_score, games_played)
                VALUES (${result.playerId}, ${result.displayName}, ${result.score}, 1)
                ON CONFLICT (player_id) DO UPDATE
                  SET total_score = leaderboard.total_score + ${result.score},
                      games_played = leaderboard.games_played + 1,
                      display_name = ${result.displayName}`);
            log:printInfo("Leaderboard updated", playerId = result.playerId, score = result.score);
        }
    }
}

service /leaderboard on new http:Listener(8091) {
    resource function get top(int 'limit = 100) returns LeaderboardRow[]|error {
        stream<LeaderboardRow, sql:Error?> rows = leaderboardDb->query(
            `SELECT * FROM leaderboard ORDER BY total_score DESC LIMIT ${'limit}`);
        return from LeaderboardRow row in rows select row;
    }
}
