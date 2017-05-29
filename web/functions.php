<?php

function setMessage($theMessage, $NextURL) {
	$_SESSION['ErrorMessage'] = $theMessage;
	header("Location: $NextURL");
}


?>

