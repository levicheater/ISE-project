<?php
if (!isset($_SESSION)) {
    session_start();
}

include 'functions.php';

if ($_SESSION['username'] == 'planner') {

$id = $_GET['id'];
$workshoptype = getWorkshopType($id);
generate_header('Reservelijst');
?>
<body>
<div class="container-fluid">
    <div class="row">
        <div class="col-md-2 col-sm-4 sidebar1">
            <div class="left-navigation">
                <ul class="list">
                    <h5><strong>Workshop Opties</strong></h5>
                    <li>
                        <a href="participants.php?id=<?php echo $id?>">Inzien deelnemers</a>
                    </li>
                    <?php
                    if($workshoptype != 'INC') {
                        echo '<li>';
                        echo  '<a href="open_registrations.php?id='.$id.'">Openstaande inschrijvingen</a>';
                        echo '</li>';
                        echo '<li>';
                        echo  '<a class="active-page">Reservelijst</a>';
                        echo '</li>';
                    }
                    ?>
                    <li>
                        <a href="editworkshop.php?id=<?php echo $id?>">Wijzig workshop</a>
                    </li>
                    <?php
                    if($workshoptype == 'INC') {
                        echo '<li>';
                        echo  '<a href="addparticipant.php?id='.$id.'">Voeg deelnemers toe</a>';
                        echo '</li>';
                    }
                    ?>
                </ul>
                <br>
            </div>
        </div>
        <div class="col-md-10 col-sm-8 main-content">
            <!--Main content code to be written here -->
            <h1>Reservelijst</h1>
            <h3>workshopnummer<?php echo $id ?></h3>
            <div>
                <table class='table table-striped table-hover'>
                    <tr>
                        <th>Nummer</th>
                        <th>Voornaam</th>
                        <th>Achternaam</th>
                        <th>Afmelden</th>
                    </tr>
                    <?php
                    //Try to make connection
                    $conn = connectToDB();

                    //Run the stored procedure
                    $sql = "exec proc_request_approved_workshop_participants_reservelist ?";
                    $stmt = $conn->prepare($sql);
                    $stmt->bindParam(1, $id, PDO::PARAM_INT);
                    $stmt->execute();

                    $nummer = 0;

                    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                        $nummer++;
                        $html = '';
                        $html .= '<tr>';
                        $html .= '<td>';
                        $html .= $nummer;
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= $row['VOORNAAM'];
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= $row['ACHTERNAAM'];
                        $html .= '</td>';
                        $html .= '<td>';
                        $html .= '<a class="fas fa-times" id="denybutton" onclick="return confirm(\'Weet je zeker dat je deze persoon wilt verwijderen? Zijn of haar gegevens worden niet opgeslagen\')" href="reservelist.php?id='.$id.'&participant_id='.$row['DEELNEMER_ID'].'&deleteUser=true"></a>';
                        $html .= '</td>';
                        $html .= '</tr>';
                        echo $html;
                    }

                    if(isset($_GET['deleteUser'])) {

                    deleteUserWorkshop($id, $_GET['participant_id']);
                    updatePage($_SERVER['PHP_SELF'].'?id='.$id);
                    }



                    ?>

                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>
<?php } else {
    echo '<h1> U mag deze pagina niet bezoeken</h1>';
}
include 'footer.html';


