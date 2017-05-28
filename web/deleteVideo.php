<?php
include 'vars.php';
include 'verifysession.php';
if ($SessionIsVerified == "1") {
    include 'head.php';
    include 'connect2db.php';
    if (isset($_REQUEST['ConfirmDelete'])) {
        $ConfirmDelete = $link->real_escape_string(trim($_REQUEST['ConfirmDelete']));
    }
    if (isset($_REQUEST['v'])) {
        $v = $link->real_escape_string(trim($_REQUEST['v']));
    }

    if ($ConfirmDelete == "Confirmed") {
    if ($isAdministrator == 1) {
        $sql = "DELETE FROM `UserVideoAssoc` WHERE `vID` == '$v'";
    } else {
        $sql = "DELETE FROM `UserVideoAssoc` WHERE `vID` == '$v' AND `vID` IN (SELECT `vID` FROM `UserVideoAssoc` WHERE `uID` = '$UserID')";
    }
    if ($link->query($sql)) {
        // good, send back to usernameTracking.
            $NextURL="home.php";
            header("Location: $NextURL");
        } else {
            // Error
            $link->close();
            setMessage($SiteErrorMessage,"verifiedPlayer.php");
        }
    } else {
        $link->close();
        setMessage($invalidData,"verifiedPlayer.php");
    }
}
?>

