<?php
if (!isset($_SESSION)) {
    session_start();
}

include 'functions.php';

generate_header('Deelnemer toevoegen');

if ($_SESSION['username'] == 'planner' or $_SESSION['username'] == 'contactpersoon') {
    $error_message = NULL;

    $workshop_id = $_GET['workshop_id'];
    $workshoptype = getWorkshopType($workshop_id);

// The ones that do not get checked are dropdown or select.
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $salutation = check_input($_POST["salutationInput"]);
        $firstname = check_input($_POST["firstnameInput"]);
        $lastname = check_input($_POST["lastnameInput"]);
        $birthDate = check_input($_POST["birthDateInput"]);
        $email = check_input($_POST["emailInput"]);
        $inlogcode = null;
        $phonenumber = check_input($_POST["phonenumberInput"]);
        $educationalAttainment = check_input($_POST["educationalAttainmentInput"]);
        $educationalAttainmentStudents = check_input($_POST["educationalAttainmentStudentsInput"]);
        $companyName = check_input($_POST["Organisation_Name"]);
        $sector = check_input($_POST["sectorInput"]);
        $Organisation_name = check_input($_POST["Organisation_Name"]);
        $functionInCompany = check_input($_POST["functionInCompanyInput"]);

        $conn = connectToDB();

        $sqlInsertDeelnemer = "SP_insert_participant_in_workshop ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?";
        $stmtInsertDeelnemer = $conn->prepare($sqlInsertDeelnemer);
        $stmtInsertDeelnemer->bindParam(1, $Organisation_name, PDO::PARAM_INT);
        $stmtInsertDeelnemer->bindParam(2, $salutation, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(3, $firstname, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(4, $lastname, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(5, $birthDate, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(6, $email, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(7, $inlogcode, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(8, $phonenumber, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(9, $educationalAttainment, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(10, $educationalAttainmentStudents, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(11, $sector, PDO::PARAM_INT);
        $stmtInsertDeelnemer->bindParam(12, $functionInCompany, PDO::PARAM_STR);
        $stmtInsertDeelnemer->bindParam(13, $workshop_id, PDO::PARAM_INT);
        try {
            $stmtInsertDeelnemer->execute();
        } catch (PDOException $e) {
            echo '<p class="alert-danger warning deletewarning">Kon deelnemer niet toevoegen.</p>';
        }

    }

    ?>
    <body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-2 col-sm-4 sidebar1">
                <div class="left-navigation">
                    <ul class="list">
                        <h5><strong>Workshop Opties</strong></h5>
                        <?php
                        if ($_SESSION['username'] == "planner") {
                            echo '<li>';
                            echo '<a href="workshop.php?workshop_id=' . $workshop_id . '">Details</a>';
                            echo '</li>';
                        } elseif ($_SESSION['username'] == "contactpersoon") {
                            echo '<li>';
                            echo '<a href="Organisatie_workshop_details.php?workshop_id=' . $workshop_id . '">Details</a>';
                            echo '</li>';
                        }
                        ?>
                        <li>
                            <a href="workshop_participants.php?workshop_id=<?= $workshop_id ?>">Deelnemers</a>
                        </li>
                        <?php
                        if ($workshoptype == "IND") {
                            echo '<li>';
                            echo '<a href="open_registrations.php?workshop_id=' . $workshop_id . '">Openstaande inschrijvingen</a>';
                            echo '</li>';
                        }
                        ?>
                        <li>
                            <a href="reservelist.php?workshop_id=<?= $workshop_id ?>">Reservelijst</a>
                        </li>
                        <?php
                        if ($_SESSION['username'] == "planner") {
                            echo '<li>';
                            echo '<a href="editworkshop.php?workshop_id=' . $workshop_id . '">Wijzig workshop</a>';
                            echo '</li>';
                        }
                        ?>
                        <li>
                            <a class="active-page">Voeg deelnemers toe</a>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="container">
                <h2 class="text-info text-center">Voeg deelnemer toe aan workshop</h2>
                <form action="addparticipant_workshop.php?workshop_id=<?= $workshop_id ?>" method="post">
                    <h3>Persoonlijke gegevens</h3>
                    <div class="form-group">
                        <label for="salutationInput">Aanhef</label>
                        <label class="radio-inline"><input type="radio" name="salutationInput" value="Dhr." checked>Dhr.</label>
                        <label class="radio-inline"><input type="radio" name="salutationInput" value="Mvr.">Mvr.</label>
                    </div>
                    <div class="form-group">
                        <label for="firstnameInput">Voornaam</label>
                        <input name="firstnameInput" type="text" class="form-control" id="firstnameInput"
                               placeholder="Voornaam"
                               required>
                    </div>
                    <div class="form-group">
                        <label for="lastnameInput">Achternaam</label>
                        <input name="lastnameInput" type="text" class="form-control" id="lastnameInput"
                               placeholder="Achternaam"
                               required>
                    </div>
                    <div class="form-group">
                        <label for="birthDateInput">Geboortedatum</label>
                        <input name="birthDateInput" type="date" class="form-control" id="birthDateInput"
                               placeholder="Geboortedatum" required>
                    </div>
                    <div class="form-group">
                        <label for="emailInput">Email</label>
                        <input name="emailInput" type="text" class="form-control" id="emailInput" placeholder="Email"
                               required>
                    </div>
                    <div class="form-group">
                        <label for="phonenumberInput">Telefoonnummer</label>
                        <input name="phonenumberInput" type="text" class="form-control" id="phonenumberInputInput"
                               placeholder="Telefoonnummer" required>
                    </div>
                    <div class="form-group">
                        <label for="educationalAttainmentInput">Opleidingsniveau</label>
                        <input name="educationalAttainmentInput" type="text" class="form-control"
                               id="educationalAttainmentInput"
                               placeholder="Opleidingsniveau" required>
                    </div>
                    <div class="form-group">
                        <label for="educationalAttainmentStudentsInput">Niveau begeleide studenten</label>
                        <input name="educationalAttainmentStudentsInput" type="text" class="form-control"
                               id="educationalAttainmentStudentsInput" placeholder="Niveau Begeleide Studenten"
                               required>
                    </div>
                    <br>
                    <h3>Gegevens bedrijf</h3>
                    <div class="form-group">
                        <label for="Organisation_Name">Naam Organisatie:</label>
                        <?php
                        echo selectBox("Organisation_Name", "Organisatie", array("Organisatienaam, organisatienummer"), "organisatienummer", array("Organisatienaam"), "Organisatienaam");
                        ?>
                    </div>
                    <div class="form-group">
                        <label for="sectorInput">Sector</label>
                        <?php
                        echo selectBox("sectorInput", "Sector", array("Sectornaam"), "Sectornaam", array("Sectornaam"), "Sectornaam");
                        ?>
                    </div>
                    <div class="form-group">
                        <label for="functionInCompanyInput">Functie in bedrijf</label>
                        <input name="functionInCompanyInput" type="text" class="form-control"
                               id="functionInCompanyInput"
                               placeholder="Functie in bedrijf" required>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-offset-5 col-sm-10">
                            <button type="submit" class="btn btn-success btn-lg">Maak deelnemer</button>
                        </div>
                    </div>
                </form>
            </div>
    </body>
    <?php
    include 'footer.php';
} else {
    notLoggedIn();
}
?>
