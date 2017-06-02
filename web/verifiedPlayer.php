<?php

include 'vars.php';
include 'verifysession.php';


if ($SessionIsVerified == "1") {
    if (isset($_REQUEST['v'])) {
        $v = $_REQUEST['v'];
        $file = pathinfo($v, PATHINFO_FILENAME);
        $ext = pathinfo($v, PATHINFO_EXTENSION);
    }
    include 'connect2db.php';
    include 'head.php';
    include 'functions.php';
    echo "<div>\n";
    echo "<video controls autoplay preload=\"auto\" src=\"stream.php?v=$v\" width=\"60%\"></video>\n";
    echo "<br><br>\n";
    echo "<form action=\"deleteVideo.php?v=$v\" method=\"post\">\n";
    echo "<input type=\"checkbox\" name=\"ConfirmDelete\" value=\"Confirmed\">Confirm Delete<br>\n";
    echo "<input type=\"submit\" value=\"Delete this video!\">\n";
    echo "</form>\n";
    echo "<br><br>\n";
    echo "Public link:<br>\n";
    echo "http://www.$domainName/player.php?v=$file.$ext";
    echo "<br><br>\n";
    echo "iframe:<br>\n";
    echo "&lt;iframe width=\"560\" height=\"315\" src=\"$domainName/stream.php?v=$v\" frameborder=\"0\" allowfullscreen&gt;&lt;/iframe&gt";
    echo "<br><br>";
    echo "html5:<br>\n";
    echo "&lt;video controls autoplay preload=\"auto\" src=\"$domainName/stream.php?v=$v\" width=\"60%\"&gt;&lt;/video&gt";
    echo "<br><br>";
    echo "Markdown:<br>\n";
    echo "[[embed url=$domainName/stream.php?v=$v]]";
    echo "<br><br>";
    echo "</div>\n";
    echo "</body></html>\n";
}
?>

