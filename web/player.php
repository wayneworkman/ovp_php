<?php

include 'vars.php';
include 'verifysession.php';

$v = $_REQUEST['v'];
$file = pathinfo($v, PATHINFO_FILENAME);
$ext = pathinfo($v, PATHINFO_EXTENSION);

if ($SessionIsVerified == "1") {
    include 'head.php';
    echo "file=$file<br>ext=$ext<br>";
    echo "<video controls autoplay preload=\"auto\" src=\"stream.php?v=$v\" width=\"60%\"></video>\n";
    echo "<br><br>\n";
    echo "iframe:<br>\n";
    echo "&lt;iframe width=\"560\" height=\"315\" src=\"http://perpetuum.io/youtube/stream.php?v=$v\" frameborder=\"0\" allowfullscreen&gt;&lt;/iframe&gt";
    echo "<br><br>";
    echo "html5:<br>\n";
    echo "&lt;video controls autoplay preload=\"auto\" src=\"http://perpetuum.io/youtube/stream.php?v=$v\" width=\"60%\"&gt;&lt;/video&gt";
    echo "<br><br>";
    echo "</body></html>\n";
} else {

    echo "<html>";
    echo "<body>\n";
    echo "<title>\n";
    echo "$v\n";
    echo "</title>\n";
    echo "<video controls autoplay preload=\"auto\" src=\"stream.php?v=$v\" width=\"60%\"></video>\n";
    echo "</body></html>\n";
}
?>

