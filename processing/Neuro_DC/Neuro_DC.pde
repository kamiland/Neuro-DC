import grafica.*;

GPointsArray[] points;
GPlot[] plot;

void setup() {
  size(1300, 700);
  background(150);

  final long numberOfProbes = 2000;
  final double timeStep = 0.001;
  final int pupulationSize = 100;
  double[] PIDparameters;

  points = new GPointsArray[2];
  points[0] = new GPointsArray((int)numberOfProbes);
  points[1] = new GPointsArray((int)numberOfProbes);

  //SinglePIDsimulator simulatorDC = new SinglePIDsimulator(100);
  //SinglePIDgeneticAlgorithm Optimization = new SinglePIDgeneticAlgorithm(numberOfProbes, pupulationSize, timeStep);
  
  DoublePIDsimulator simulatorDC = new DoublePIDsimulator(100);
  DoublePIDgeneticAlgorithm Optimization = new DoublePIDgeneticAlgorithm(numberOfProbes, pupulationSize, timeStep);

  Optimization.SetSquareErrorIntegral();

  for (int i = 0; i < 30; i++)
  {
    println("\niteration: ", i);
    Optimization.doOneGeneration();
    Optimization.showBest();
  }

  PIDparameters = Optimization.showBest();

  //simulatorDC.PID.Kp = PIDparameters[0];
  //simulatorDC.PID.Ki = PIDparameters[1];
  //simulatorDC.PID.Kd = PIDparameters[2];

  simulatorDC.angularPID.Kp = PIDparameters[0];
  simulatorDC.angularPID.Ki = PIDparameters[1];
  simulatorDC.angularPID.Kd = PIDparameters[2];

  simulatorDC.currentPID.Kp = PIDparameters[3];
  simulatorDC.currentPID.Ki = PIDparameters[4];
  simulatorDC.currentPID.Kd = PIDparameters[5];

  simulatorDC.Simulate(numberOfProbes, timeStep, points);


  plot = new GPlot[2];
  plot[0] = new GPlot(this);
  plot[1] = new GPlot(this);
}

void draw()
{
  drawPlots(plot, points);
}
