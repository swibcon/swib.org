---
pagetitle: "SWIB24: Lightning Talks"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Lightning Talks</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Huda Khan, Nuno Freire</div>

    



## Chatbot assistant for searching the Finna.fi LAM discovery portal

<b><u>Osma Suominen</u>, <u>Unni Kohonen</u>, <u>Saga Jacksen</u></b>



## Northwestern University’s Wikidata Workflow Experiment

<b><u>Abby Dover</u></b>



## The BIBFRAMINATOR

<b><u>Jim Hahn</u></b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2024-11-27T14:00:00");

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


