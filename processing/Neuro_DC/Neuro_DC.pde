import grafica.*;

void setup() {
  size(950, 500);
  background(150);

  Simulator simulatorDC = new Simulator();
  long numberOfProbes = 1000;
  double timeStep = 0.001;

  GPointsArray[] points = new GPointsArray[2];
  points[0] = new GPointsArray((int)numberOfProbes);
  points[1] = new GPointsArray((int)numberOfProbes);

  simulatorDC.Simulate(numberOfProbes, timeStep, points);

  GPlot[] plot = new GPlot[2];
  plot[0] = new GPlot(this);
  plot[1] = new GPlot(this);

  draw(plot, points);
}
