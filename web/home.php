<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'head.php';
    include 'connect2db.php';
    echo "<div>\n";
    if ($isAdministrator == 1) {
        $sql = "SELECT `vID`,`uploadDate`,`vTitle`,`vCount` from `Videos` ORDER BY `uploadDate` DESC";
    } else {
        $sql = "SELECT `vID`,`uploadDate`,`vTitle`,`vCount` from `Videos` WHERE `vID` IN (SELECT `vID` FROM `UserVideoAssoc` WHERE `uID` = '$UserID') ORDER BY `uploadDate` DESC";
    }
    //echo "$sql<br>\n";
    $result = $link->query($sql);
    if ($result->num_rows > 0) {
        echo "<table style=\"width:100%\">\n";
        echo "<tr>\n";
        echo "<th>Title</th>\n";
        echo "<th>Count</th>\n";
        echo "<th>date</th>\n";
        echo "</tr>\n";
        while($row = $result->fetch_assoc()) {
            echo "<tr>\n";
            echo "<td><a href=\"verifiedPlayer.php?v=" . trim($row['vID']) . "\">" . trim($row['vTitle']) . "</a></td>\n";
            echo "<td>" . trim($row['vCount']) . "</td>\n";
            echo "<td>" . trim($row['uploadDate']) . "</td>\n";
            echo "</tr>\n";
        }
        echo "</table>\n";
        $result->free();
    } else {
        echo "You have not uploaded any videos yet.<br>You might want to read the <a href=\"showWelcome.php\">Welcome</a> page.";
    }
    echo "</div>\n";
    echo "</body>";
    echo "</html>";
}
?>
