import grafica.*;

GPointsArray[] points;
GPlot[] plot;

void setup() {
  size(1300, 700);
  background(150);

  SinglePIDsimulator simulatorDC = new SinglePIDsimulator();
  //DoublePIDSimulator simulatorDC = new DoublePIDSimulator();

  final long numberOfProbes = 2000;
  final double timeStep = 0.001;

  points = new GPointsArray[2];
  points[0] = new GPointsArray((int)numberOfProbes);
  points[1] = new GPointsArray((int)numberOfProbes);

  

  double[] PIDparameters;
  SinglePIDGeneticAlgorithm Optimization = new SinglePIDGeneticAlgorithm(numberOfProbes, 100, timeStep);
  
  Optimization.SetAbsoluteErrorIntegral();
  
  for (int i = 0; i < 30; i++)
  {
    Optimization.doOneGeneration();
  }
  PIDparameters = Optimization.showBest();
  simulatorDC.PID.Kp = PIDparameters[0];
  simulatorDC.PID.Ki = PIDparameters[1];
  simulatorDC.PID.Kd = PIDparameters[2];
  simulatorDC.Simulate(numberOfProbes, timeStep, points);


  plot = new GPlot[2];
  plot[0] = new GPlot(this);
  plot[1] = new GPlot(this);
}

void draw()
{
  drawPlots(plot, points);
}
