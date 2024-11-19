---
pagetitle: "SWIB24: Vocabularies"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Vocabularies</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Jakob Voß, Osma Suominen</div>

    



## This is an ontology, not a screwdriver

<b><u>Helena Simões Patrício</u>, Maria Inês Cordeiro, Pedro Nogueira Ramos</b>



## Examining LGBTQ+-related concepts and their links in the Semantic Web

<b><u>Shuai Wang</u>, Maria Adamidou</b>



## A web-based translation interface for the MeSH vocabulary

<b><u>Lukas Geist</u>, Nelson Quiñones, Rohitha Ravinder, Dietrich Rebholz-Schuhmann, Gabriele Wollnik-Korn, Miriam Albers, Leyla Jael Castro</b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2024-11-27T15:30:00");

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


