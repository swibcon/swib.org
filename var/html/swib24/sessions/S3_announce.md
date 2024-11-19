---
pagetitle: "SWIB24: Generating Linked Metadata"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Generating Linked Metadata</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Adrian Pohl, Niklas Lindström</div>

    



## Automating metadata extraction and cataloguing: experiences from the National Libraries of Norway and Finland

<b><u>Pierre Beauguitte</u>, <u>Osma Suominen</u></b>



## MARC21 bibliographic to LRM/RDA/RDF mapping and conversion project

<b><u>Crystal Elisabeth Yragui</u>, <u>Junghae Lee</u>, <u>Cypress Payne</u></b>



## ANTELOPE: open source service for accessible semantic annotation in GLAM

<b><u>Kolja Bailly</u>, Lozana Rossenova, Ina Blümel, Thassilo Schiepanski</b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2024-11-26T14:00:00");

  var x = setInterval(function() {
    var now = moment();
    var t = startDate - now;

    var days = Math.floor( t / ( 1000 * 60 * 60 * 24 ));
    var hours = Math.floor((t%(1000 * 60 * 60 * 24))/(1000 * 60 * 60));
    var minutes = Math.floor((t % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((t % (1000 * 60)) / 1000);

    document.getElementById("countdown").innerHTML = days + "d "
        + hours + "h " + minutes + "m " + seconds + "s ";
    if (t < 0) {
      clearInterval(x);
      document.getElementById("countdown").innerHTML = "STARTING ...";
    }
  }, 1000);
</script>


