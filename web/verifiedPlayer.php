<?php

include 'vars.php';
include 'verifysession.php';

$v = $_REQUEST['v'];
$file = pathinfo($v, PATHINFO_FILENAME);
$ext = pathinfo($v, PATHINFO_EXTENSION);

if ($SessionIsVerified == "1") {
    include 'head.php';
    echo "<div>\n";
    echo "<video controls autoplay preload=\"auto\" src=\"stream.php?v=$v\" width=\"60%\"></video>\n";
    echo "<br><br>\n";
    echo "<form action=\"deleteVideo.php\" method=\"post\">\n";
    echo "<input type=\"checkbox\" name=\"ConfirmDelete\" value=\"Confirmed\">Confirm Delete<br>\n";
    echo "<input type=\"submit\" value=\"Delete this video!\">\n";
    echo "</form>\n";
    echo "<br><br>\n";
    echo "Public link:<br>\n";
    echo "$domainName/player.php?v=$file.$ext";
    echo "<br><br>\n";
    echo "iframe:<br>\n";
    echo "&lt;iframe width=\"560\" height=\"315\" src=\"$domainName/stream.php?v=$v\" frameborder=\"0\" allowfullscreen&gt;&lt;/iframe&gt";
    echo "<br><br>";
    echo "html5:<br>\n";
    echo "&lt;video controls autoplay preload=\"auto\" src=\"$domainName/stream.php?v=$v\" width=\"60%\"&gt;&lt;/video&gt";
    echo "<br><br>";
    echo "</div>\n";
    echo "</body></html>\n";
}
?>

