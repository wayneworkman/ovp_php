<?php

$v = $_REQUEST['v'];
$file = pathinfo($v, PATHINFO_FILENAME);
$ext = pathinfo($v, PATHINFO_EXTENSION);
echo "<video controls autoplay preload=\"auto\" src=\"stream.php?v=$v\" width=\"60%\"></video>\n";
?>

