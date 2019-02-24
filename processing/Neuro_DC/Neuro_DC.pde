import grafica.*;

GPointsArray[] points;
GPlot[] plot;

void setup() {
  size(1300, 700);
  background(150);

  Simulator simulatorDC = new Simulator();
  final long numberOfProbes = 5000;
  final double timeStep = 0.0001;

  points = new GPointsArray[2];
  points[0] = new GPointsArray((int)numberOfProbes);
  points[1] = new GPointsArray((int)numberOfProbes);

  simulatorDC.Simulate(numberOfProbes, timeStep, points);

  plot = new GPlot[2];
  plot[0] = new GPlot(this);
  plot[1] = new GPlot(this);

  
}

void draw()
{
  drawPlots(plot, points);
}
