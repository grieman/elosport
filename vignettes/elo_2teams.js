// !preview r2d3 data=dy_prep[dy_prep$Team %in% c('Leicester', 'Wasps', 'Gloucester', 'Bath', 'Harlequins', 'Saracens', 'NorthamptonSaints', 'Sale'), ]
//
// r2d3: https://rstudio.github.io/r2d3
//

var parseTime = d3.timeParse("%Y-%m-%d");

var format1 = d3.format(".1f");

var margin = {top: 30, right: 30, bottom: 50, left: 60}
  , width = window.innerWidth - margin.left - margin.right
  , height = window.innerHeight - margin.top - margin.bottom;

var x = d3.scaleTime()
    .domain(d3.extent(data, function(d) { return parseTime(d.Date); }))
    .range([margin.left, width-margin.right]); // output

var y = d3.scaleLinear()
    .domain(d3.extent(data, function(d) { return d.Elo; }))
    .range([height-margin.bottom, margin.top]); // output

xAxis = svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + (height - margin.bottom) + ")")
    .call(d3.axisBottom(x));

svg.append("text")
      .attr("y", height)
      .attr("x",(width/2))
      .style("text-anchor", "middle")
      .text("Date");

svg.append("text")
        .attr("y", margin.top)
        .attr("x", (width / 2))
        .attr("text-anchor", "middle")
        .style("font-size", "16px")
        .style("text-decoration", "underline")
        .text("ELO Scores of English Premiership Clubs");

svg.append("text")
        .attr("y", margin.top+15)
        .attr("x", (width / 2))
        .attr("text-anchor", "middle")
        .style("font-size", "10px")
        .text("Zoom along x-axis, double click to reset");

yAxis = svg.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + margin.left + ",0)")
    .call(d3.axisLeft(y)); // Create an axis component with d3.axisLeft

svg.append("text")
  .attr("transform", "rotate(-90)")
  .attr("y", 0)
  .attr("x",0 - (height / 2))
  .attr("dy", "1em")
  .style("text-anchor", "middle")
  .text("ELO Score");


d3.select('body')
  .append('div')
  .attr('id', 'tooltip')
  .attr('style', 'position: absolute; opacity: 0; background: white; border-radius: 8px;')
  .html('placeholder')

var sumstat = d3.nest()
    .key(function(d) { return d.Team;})
    .entries(data);

var res = sumstat.map(function(d){ return d.key })
var color = d3.scaleOrdinal()
  .domain(res)
  .range(['#1b9e77','#d95f02','#7570b3','#e7298a','#66a61e','#e6ab02','#a6761d','#666666'])


var series = svg.selectAll(".series")
        .data(sumstat)
        .enter().append("g")
        .attr("class", "series")
        .attr("clip-path", "url(#clip)")


series
      .append("path")
        .attr("fill", "none")
        .attr("stroke", function(d){ return color(d.key) })
        .attr("stroke-width", 6)
        .attr("opacity", 0.2)
        .attr("d", function(d){
          return d3.line()
            .x(function(d) { return x(parseTime(d.Date)); })
            .y(function(d) { return y(d.Elo); })
            .curve(d3.curveMonotoneX)
            (d.values)
        })
  .on("mouseover", handleMouseOver)
  .on("mousemove", handleMouseMove)
  .on("mouseout", handleMouseOut)
  .on("click", handleClick);





  function handleMouseOver(d, i) {
      d3.select(this).transition().attr("stroke-width", 8);
      d3.select(this).transition().attr('opacity', this.opacity = (this.opacity == 1 ? 1 : .5));
      d3.select('#tooltip').transition().style('opacity', 1);
          }

function handleMouseMove(d, i) {
      d3.select('#tooltip')
      .style('left', d3.event.pageX + 10 + 'px')
      .style('top', d3.event.pageY + 10 + 'px');
      d3.select('#tooltip').html(d.key + "<br/> ELO Score: " + format1(y.invert(d3.event.pageY)));
          }


function handleMouseOut(d, i) {
      d3.select(this).transition().attr("stroke-width", 6);
      d3.select(this).transition().attr('opacity', this.opacity = (this.opacity == 1 ? 1 : .2));
      d3.select('#tooltip').style('opacity', 0);
          }

function handleClick(d, i) {
      d3.select(this).transition().attr('opacity', this.opacity = (this.opacity == 1 ? 0.2 : 1));
    }

//TO DO - port over zoom from elo_chart.js

    // Add a clipPath: everything out of this area won't be drawn.
    var clip = svg.append("defs").append("svg:clipPath")
        .attr("id", "clip")
        .append("svg:rect")
        .attr("width", width-margin.right-margin.left)
        .attr("height", height-margin.bottom )
        .attr("x", margin.left)
        .attr("y", margin.top);

    // Add brushing
    var brush = d3.brushX()                   // Add the brush feature using the d3.brush function
        .extent([[margin.left,(height-margin.bottom)], [(width - margin.right),(height)]])
        .on("end", updateChart)

    svg
      .append("g")
        .attr("class", "brush")
        .call(brush)
        .call(brush.move, [(width - margin.right - 25), (width - margin.right)])

    var idleTimeout
    function idled() { idleTimeout = null; }

   // A function that update the chart for given boundaries
    function updateChart() {

      // What are the selected boundaries?
      extent = d3.event.selection

      // If no selection, back to initial coordinate. Otherwise, update X axis domain
      if(!extent){
        if (!idleTimeout) return idleTimeout = setTimeout(idled, 350); // This allows to wait a little bit
        x.domain([ 4,8])
      }else{
        x.domain([ x.invert(extent[0]), x.invert(extent[1]) ])
        svg.select(".brush").call(brush.move, null) // This remove the grey brush area as soon as the selection has been done
      }

      // Update axis and line position
      xAxis.transition().duration(1000).call(d3.axisBottom(x))
      series
          .select('path')
          .transition()
          .duration(1000)
          .attr("d", function(d){
          return d3.line()
            .x(function(d) { return x(parseTime(d.Date)); })
            .y(function(d) { return y(d.Elo); })
            .curve(d3.curveMonotoneX)
            (d.values)
        })
    }

    svg.on("dblclick",function(){
      x.domain(d3.extent(data, function(d) { return parseTime(d.Date); }))
      xAxis.transition().call(d3.axisBottom(x))
      series
        .select('path')
        .transition()
        .attr("d", function(d){
          return d3.line()
            .x(function(d) { return x(parseTime(d.Date)); })
            .y(function(d) { return y(d.Elo); })
            .curve(d3.curveMonotoneX)
            (d.values)
        })
    });

