---
pagetitle: "SWIB24: Workflows"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Workflows</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div>Moderators: Huda Khan, Nuno Freire</div>

    



## Leveraging Linked Data Fragments for enhanced data publication: the Share-VDE case study

<b><u>Andrea Gazzarini</u></b>



## Constraints for Linked Open Data

<b><u>Shawn Goodwin</u></b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("2024-11-27T14:25:00");

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


