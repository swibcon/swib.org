---
pagetitle: "SWIB24: Opening"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Opening</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Anna Kasprzik, Katherine Thornton</div>

    



## Welcome

<b><u>N.N. N.N.</u></b>



## Keynote: How knowledge representation is changing in a world of large language models

<b><u>Denny Vrandečić</u></b>



## Community-based development of a metadata profile for educational resources

<b><u>Adrian Pohl</u>, <u>Manuel Kummerländer</u></b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2024-11-25T14:00:00");

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


