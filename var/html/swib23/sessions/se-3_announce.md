---
pagetitle: "SWIB22: Linked Library Data II"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Linked Library Data II</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Julia Beck, Joachim Neubert</div>

    



## BIBFRAME for academic publishing in psychology

<b><u>Tina Trillitzsch</u></b>



## On leveraging artifical intelligence and natural language processing to create an open source workflow for the rapid creation of archival linked data for digital collections

<b><u>Jennifer Erin Proctor</u></b>



## Library data on Wikidata: a case study of the National Library of Latvia

<b><u>Eduards Skvireckis</u></b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2022-11-29T14:00:00");

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


