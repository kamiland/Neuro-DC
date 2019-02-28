import grafica.*;

GPointsArray[] points;
GPlot[] plot;

void setup() {
  size(1300, 700);
  background(150);

  SinglePIDSimulator simulatorDC = new SinglePIDSimulator();
  //DoublePIDSimulator simulatorDC = new DoublePIDSimulator();

  final long numberOfProbes = 1000;
  final double timeStep = 0.001;

  points = new GPointsArray[2];
  points[0] = new GPointsArray((int)numberOfProbes);
  points[1] = new GPointsArray((int)numberOfProbes);

  

  double[] PID;
  GeneticAlgorithm Optimization = new GeneticAlgorithm(numberOfProbes, 100, timeStep);
  
  Optimization.SetAbsoluteErrorIntegral();
  
  for (int i = 0; i < 30; i++)
  {
    Optimization.doOneGeneration();
  }
  PID = Optimization.showBest();
  simulatorDC.PID.Kp = PID[0];
  simulatorDC.PID.Ki = PID[1];
  simulatorDC.PID.Kd = PID[2];
  simulatorDC.Simulate(numberOfProbes, timeStep, points);


  plot = new GPlot[2];
  plot[0] = new GPlot(this);
  plot[1] = new GPlot(this);
}

void draw()
{
  drawPlots(plot, points);
}
