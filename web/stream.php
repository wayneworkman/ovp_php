<?php

include 'vars.php';

$v = $_REQUEST['v'];
$file = pathinfo($v, PATHINFO_FILENAME);
$ext = pathinfo($v, PATHINFO_EXTENSION);
$file = "$videoDir/$file.$ext";



$stream = "";
$buffer = 102400;
$start = -1;
$end = -1;
$size = 0;


//Open Stream
if (!($stream = fopen($file, 'rb'))) {
    die('Could not open stream for reading');
}


//Set header
ob_get_clean();
header("Content-Type: video/$ext");
header("Cache-Control: max-age=2592000, public");
header("Expires: ".gmdate('D, d M Y H:i:s', time()+2592000) . ' GMT');
header("Last-Modified: ".gmdate('D, d M Y H:i:s', @filemtime($file)) . ' GMT' );
$start = 0;
$size = filesize($file);
$end = $size - 1;
header("Accept-Ranges: 0-".$end);
         
if (isset($_SERVER['HTTP_RANGE'])) {
    $c_start = $start;
    $c_end = $end;
 
    list(, $range) = explode('=', $_SERVER['HTTP_RANGE'], 2);
    if (strpos($range, ',') !== false) {
        header('HTTP/1.1 416 Requested Range Not Satisfiable');
        header("Content-Range: bytes $start-$end/$size");
        exit;
    }
    if ($range == '-') {
        $c_start = $size - substr($range, 1);
    } else {
        $range = explode('-', $range);
        $c_start = $range[0];
        $c_end = (isset($range[1]) && is_numeric($range[1])) ? $range[1] : $c_end;
    }
    $c_end = ($c_end > $end) ? $end : $c_end;
    if ($c_start > $c_end || $c_start > $size - 1 || $c_end >= $size) {
        header('HTTP/1.1 416 Requested Range Not Satisfiable');
        header("Content-Range: bytes $start-$end/$size");
        exit;
    }
    $start = $c_start;
    $end = $c_end;
    $length = $end - $start + 1;
    fseek($stream, $start);
    header('HTTP/1.1 206 Partial Content');
    header("Content-Length: ".$length);
    header("Content-Range: bytes $start-$end/".$size);
} else {
    header("Content-Length: ".$size);
}


#Begin Stream.
$i = $start;
set_time_limit(0);
while(!feof($stream) && $i <= $end) {
    $bytesToRead = $buffer;
    if(($i+$bytesToRead) > $end) {
        $bytesToRead = $end - $i + 1;
    }
    $data = fread($stream, $bytesToRead);
    echo $data;
    flush();
    $i += $bytesToRead;
}


#End
fclose($stream);
exit;

?>

