var datapoints;

window.onload = function () {

    $.getJSON('http://data.blockframe.xyz:8000/last/100', function (data) {

        datapoints = data.map(function(element)  {

            return {

                x: element.height,

                y: [

                    element.candle.candle.open,
                    element.candle.candle.high,
                    element.candle.candle.low,
                    element.candle.candle.close

                ],

                //label: new Date(element.candle.candle.mts).toLocaleDateString().toString() + ' - ' + element.height.toString()
                label: element.height

            };

        });

        var chart = new CanvasJS.Chart("chartContainer",
            {
                title: {
                    text: "Price X Blockframe Height "
                },
                zoomEnabled: true,
                axisY: {
                    includeZero: false,
                    title: "Prices",
                    prefix: "$ "
                },
                axisX: {
                    interval: 2,
                    intervalType: "number",
                    //valueFormatString: "MMM-YY",
                    title: "Block Height",
                    labelAngle: -45,
                    labelFontSize: 11
                },
                data: [
                    {
                        type: "candlestick",
                        risingColor: "#F79B8E",
                        dataPoints: datapoints

                    }
                ]
            });
        chart.render();
    })
};