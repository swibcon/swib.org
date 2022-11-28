---
pagetitle: "SWIB22: Tutorials and Workshops"
---


<div id="top">
<div class="column left">![](../images/swib.png "swib logo")</div>
<div class="column middle">Tutorials and Workshops</div>
<div id="countdown" class="column right"></div>
</div>

<div id="prog">
<div></div>

    



## all booked out

<b></b>



## Next conference session at Thursday 14 h UTC

<b></b>



</div>



<script src="../scripts/moment.min.js"></script>
<script>
  var startDate = moment.utc("--T::00");

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


