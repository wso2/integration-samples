public function getMusicMoodForWeather(int weatherCode) returns string {
    match weatherCode {
        1000 => {
            return "Upbeat";
        }
        1003|1006 => {
            return "Chill";
        }
        1009 => {
            return "Alternative";
        }
        1030|1135|1147 => {
            return "Ambient";
        }
        1063|1150|1153|1180|1183|1240 => {
            return "Calm";
        }
        1087|1273|1276 => {
            return "Epic";
        }
        1066|1210|1213|1216|1219|1255 => {
            return "Dreamy";
        }
        1114|1117 => {
            return "Dark";
        }
        1168|1171|1198|1201 => {
            return "Classical";
        }
        1192|1195|1243|1246 => {
            return "Melancholic";
        }
        _ => {
            return "Pop";
        }
    }
}
