<?php
require 'functions.php';

if (!isset($_SESSION)) {
    session_start();
}

generate_header('Homepage');

if (isset($_GET['logout'])) {
    unset($_SESSION['username']);
    unset($_SESSION['organisation']);
    unset($_SESSION['deelnemer_id']);
    unset($_SESSION['planner']);
    header('Location:  ' . $_SERVER['PHP_SELF']);
}


if (isset($_GET['organisation_id'])) {
    $_SESSION['username'] = 'contactpersoon';
    $_SESSION['organisation'] = $_GET['organisation_id'];
    header('Location:  ' . $_SERVER['PHP_SELF']);
} elseif (isset($_GET['planner'])) {
    $_SESSION['username'] = 'planner';
    $_SESSION['planner'] = $_GET['planner'];
    header('Location:  ' . $_SERVER['PHP_SELF']);
} elseif (isset($_GET['beheerder'])) {
    $_SESSION['username'] = 'beheerder';
    header('Location:  ' . $_SERVER['PHP_SELF']);
} elseif (isset($_GET['email'])) {
    if (!is_null(getParticipantId($_GET['email'], $_GET['code']))) {
        $_SESSION['username'] = 'deelnemer';
        $_SESSION['deelnemer_id'] = getParticipantId($_GET['email'], $_GET['code']);
        header('Location:  ' . $_SERVER['PHP_SELF']);
    } else {
        header('Location: index.php');

    }
}

function getParticipantId($email, $code)
{

    $conn = connectToDB();
    $sql = "select deelnemer_id from DEELNEMER where email = ? and inlogcode = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(1, $email, PDO::PARAM_STR);
    $stmt->bindParam(2, $code, PDO::PARAM_STR);
    try {
        $stmt->execute();
    } catch (PDOException $e) {
        echo '<p class="alert-danger warning deletewarning">Kan deelnemer niet ophalen.</p>';
    }

    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row['deelnemer_id'];

}

?>
<body>
<h1 class="text-center">Workshopomgeving SBB</h1>
<div class="img">
    <img src="Images/sbblogo.jpg" width="350" height="300" title="sbblogo" alt="sbblogo"/>
</div>
<br>
<?php if (!isset($_SESSION['username'])) {
    if ((!isset($_POST['planner'])) && (!isset($_POST['deelnemer'])) && (!isset($_POST['contactpersoon'])) && (!isset($_POST['beheerder']))) { ?>

        <h3 class="text-center">Login als Planner / Leerbedrijf / Deelnemer / Beheerder</h3>
        <br>
        <div class="container">
            <div class="row justify-content-md-center">
                <form class="form-horizontal" name="login" action="" method="post">
                    <input align="right" type="submit" name="planner" value="Planner"/>
                    <input align="right" type="submit" name="contactpersoon" value="Contactpersoon"/>
                    <input class="text-center" type="submit" name="deelnemer" value="Deelnemer"/>
                    <input align="right" type="submit" name="beheerder" value="Beheerder"/>
                </form>
            </div>
        </div>
    <?php }
} elseif (isset($_SESSION['username'])) { ?>
    <div class="container">
        <h3 class="text-center">Je bent ingelogt als <?= $_SESSION['username'] ?></h3>
        <div class="row justify-content-md-center">
            <a class="btn btn-danger btn-lg" href="?logout=1">Logout</a>
        </div>
    </div>

    <?php
}
if (isset($_POST['planner'])) { ?>
    <div class="container">
        <h3 class="text-center">Kies hieronder uw account</h3>
        <div class="row justify-content-md-center">
            <?php echo selectBox("Coordination_Contact", "planner", array("plannernaam"), "plannernaam", array("plannernaam"), "plannernaam", NULL, "IS_ACTIEF = 1"); ?>
        </div>
        <br>
        <div class="row justify-content-md-center">
            <button class="btn btn-success btn-lg" onclick="setPlanner()">Login</button>
        </div>
    </div>
    <?php
} elseif (isset($_POST['contactpersoon'])) {
    ?>
    <div class="container">
        <h3 class="text-center">Kies hieronder uw organisatie</h3>
        <div class="row justify-content-md-center">
            <?php
            echo selectBox("Organisation_Name", "Organisatie", array("Organisatienaam", "ORGANISATIENUMMER"), "ORGANISATIENUMMER", array("Organisatienaam"), "Organisatienaam");
            ?>
        </div>
        <br>
        <div class="row justify-content-md-center">
            <button class="btn btn-success btn-lg" onclick="setOrganisation()">Login</button>
        </div>
    </div>
    <?php
} elseif (isset($_POST['deelnemer'])) {
    ?>
    <div class="container">
        <h3 class="text-center">Log hieronder in met uw email en code</h3>
        <div class="row justify-content-md-center">
            <input id="email" type="email" class="form-control" placeholder="Email" name="email" required>
            <br>
            <input id="code" type="password" class="form-control" placeholder="Code" name="code" required>
            <br>
            <button class="btn btn-success btn-lg" onclick="setParticipant()">Login</button>
        </div>
    </div>
    <?php
} elseif (isset($_POST['beheerder'])) {
    ?>
    <div class="container">
        <h3 class="text-center">Log hieronder in met uw beheerdersaccount</h3>
        <div class="row justify-content-md-center">
            <input id="usernameB" type="text" class="form-control" placeholder="gebruikersnaam" name="usernameB"
                   required>
            <br>
            <input id="passwordB" type="password" class="form-control" placeholder="wachtwoord" name="passwordB"
                   required>
            <br>
            <button class="btn btn-success btn-lg" onclick="setManager()">Login</button>
        </div>
    </div>
    <?php
}

include 'footer.php'; ?>
<script>
    function setOrganisation() {
        var element = document.getElementById('Organisation_Name').value;
        if (element !== "") {
            window.location.href = "index.php?organisation_id=" + element;
        } else {
            alert("Kies aub een organisatie")
        }
    }

    function setPlanner() {
        var element = document.getElementById('Coordination_Contact').value;
        if (element !== "") {
            window.location.href = "index.php?planner=" + element;
        } else {
            alert("Kies aub een Planner")
        }
    }

    function setParticipant() {
        var element = document.getElementById('email').value;
        var element2 = document.getElementById('code').value;
        if (element !== "" && element2 !== "") {
            window.location.href = "index.php?email=" + element + "&code=" + element2;
        } else {
            alert("Log aub in")
        }
    }

    function setManager() {
        var username = document.getElementById('usernameB').value;
        var password = document.getElementById('passwordB').value;
        if (username === "beheerder" && password === "bG56F12pp") {
            window.location.href = "index.php?beheerder=" + username
        } else {
            alert("Log aub met een bestaand account in")
        }
    }
</script>



