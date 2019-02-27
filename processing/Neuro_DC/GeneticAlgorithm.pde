public class GeneticAlgorithm
{
  SinglePIDSimulator[] engines;
  SinglePIDSimulator[] nextGenerationEngines;
  SinglePIDSimulator best = new SinglePIDSimulator();

  /*static*/ int populationSize; /**ilość osobników w populacji   */
  int generationCounter = 0;

  double bestFit = 0;
  double[] objectParameters;

  double rand;

  double P_range = 10;
  double I_range = 10;
  double D_range = 10;

  long numberOfProbes; /** ilość próbek symulacji   */
  double timeStep = 0.0001;

  public GeneticAlgorithm(long _numberOfProbes, int _pupulationSize, double[] _objectParameters, double _timeStep)
  {
    numberOfProbes = _numberOfProbes;
    populationSize = _pupulationSize;
    objectParameters = _objectParameters;
    engines = new SinglePIDSimulator[populationSize];
    nextGenerationEngines = new SinglePIDSimulator[populationSize];
    timeStep = _timeStep;

    for (int i = 0; i < populationSize; i++)
    {
      engines[i] = new SinglePIDSimulator();
      engines[i].PID.Kp = ((Math.random() * 2.0) - 1.0) * P_range; //randomize a P value between -P_range and P_range
      engines[i].PID.Ki = ((Math.random() * 2.0) - 1.0) * I_range;
      engines[i].PID.Kd = ((Math.random() * 2.0) - 1.0) * D_range;
    }
  }

  //Przeprowadzenie jednej generacji aż do momentu powstania nowej
  public void doOneGeneration()
  {
    for (int i = 0; i < populationSize; i++)
    {
      engines[i].Simulate(numberOfProbes, timeStep);
    }
    normalizeFitness();
    nextGeneration();
    generationCounter++;
  }


  //Wyświetla najlepszy wynik operacji numerycznych. 
  //zmienic nazwe lub sposób działania bo ta metoda nic nie pokazuje
  public double[] showBest()
  {
    best.Simulate(numberOfProbes, timeStep);
    double[] PID = { best.PID.Kp, best.PID.Ki, best.PID.Kd };
    //Window1 graphWindow = new Window1();
    //graphWindow.Show();

    return PID;
  }


  //Utworzenie nowej generacji z bieżącej generacji
  void nextGeneration()
  {
    normalizeFitness();

    for (int i = 0; i < populationSize; i++)
    {
      rand = Math.random();
      if (rand >= 0.5)
      {
        pickTweak(i);  /**50% szans na przekazanie   */
      } else if (rand >= 0.1)
      {
        pickAndCross(i); /** 40% szans skrzyżowania  */
      } else
      {
        mutatant(i); /** 10% szans na losowe nastawy PID */
      }
    }

    for (int i = 0; i < populationSize; i++)
      engines[i] = nextGenerationEngines[i];
  }


  //Wybór jednego osobnika z populacji oraz delikatna modyfikacja jego nastaw
  void pickTweak(int i)
  {
    SinglePIDSimulator parent = new SinglePIDSimulator();
    int x;
    boolean picked;

    if (Math.random() > 0.01)
    {
      picked = false;
      do
      {
        x = (int)(Math.random() * populationSize); 
        if (Math.random() <= engines[x].fitness)
        {
          parent = engines[x];
          picked = true;
        }
      } 
      while (!picked);
    } else
    {
      parent = best;
    }
    nextGenerationEngines[i] = tweak(parent);
  }


  //Wybieranie dwóch osobników z populacji oraz krzyżowanie ich.
  void pickAndCross(int i)
  {
    SinglePIDSimulator parent_a = new SinglePIDSimulator();
    int a;
    SinglePIDSimulator parent_b = new SinglePIDSimulator();
    int b;
    boolean picked;

    picked = false;
    do
    {
      a = (int)(Math.random() * populationSize);
      if (Math.random() <= engines[a].fitness)
      {
        parent_a = engines[a];
        picked = true;
      }
    } 
    while (!picked);
    if (Math.random() > 0.01)
    {
      picked = false;
      do
      {
        b = (int)(Math.random() * populationSize);
        if (a != b && (Math.random() <= engines[b].fitness))
        {
          parent_b = engines[b];
          picked = true;
        }
      } 
      while (!picked);
    } else
      parent_b = best; // 1% chance of picking "best" as a pair to cross with
    nextGenerationEngines[i] = cross(parent_a, parent_b);
  }

  //Normalizacja wartości fitness wszystkich osobników tak aby były wartościami od 0 do 1
  void normalizeFitness()
  {
    double maxFit = 0;
    double minFit;

    //Oszacowanie maksymalnej wartości fit.
    for (int i = 0; i < populationSize; i++)
    {
      if (engines[i].fitness > maxFit)
      {
        maxFit = engines[i].fitness;
        if (maxFit > bestFit)
        {
          bestFit = maxFit;
          best = engines[i];
        }
      }
    }
    //Oszacowanie minimalnej wartości fit.
    minFit = maxFit;
    for (int i = 0; i < populationSize; i++)
    {
      minFit = engines[i].fitness < minFit ? engines[i].fitness : minFit;
    }

    if (maxFit != 0)
      for (int i = 0; i < populationSize; i++)
      {
        engines[i].fitness -= minFit;
        engines[i].fitness /= (maxFit - minFit);
      }
  }


  //Funkcja tworząca nowy losowy organizm
  void mutatant(int i)
  {
    SinglePIDSimulator child = new SinglePIDSimulator();
    child.PID.Kp = ((Math.random() * 2.0) - 1.0) * P_range; //randomize a P value between -P_range and P_range
    child.PID.Ki = ((Math.random() * 2.0) - 1.0) * I_range;
    child.PID.Kd = ((Math.random() * 2.0) - 1.0) * D_range;
    if (Math.random() > 0.01) nextGenerationEngines[i] = child;
    else nextGenerationEngines[i] = best; // 1% chance of picking "best" as a mutant
  }


  //Funkcja delikatnie modyfikująca jeden organizm
  SinglePIDSimulator tweak(SinglePIDSimulator parent) 
  {
    SinglePIDSimulator child = new SinglePIDSimulator();
    child.PID.Kp = parent.PID.Kp + (Math.random() * 2.0) - 1.0; // value of P +- random between 0 and 1
    child.PID.Ki = parent.PID.Ki + (Math.random() * 2.0) - 1.0;
    child.PID.Kd = parent.PID.Kd + (Math.random() * 2.0) - 1.0;
    return child;
  }


  //  Funkcja krzyrzująca dwa organizmy
  SinglePIDSimulator cross(SinglePIDSimulator parent_a, SinglePIDSimulator parent_b)
  {
    SinglePIDSimulator child = new SinglePIDSimulator();
    double crossingPoint = Math.random();
    child.PID.Kp = parent_a.PID.Kp * crossingPoint + parent_b.PID.Kp * (1.0 - crossingPoint); // picking a new P value in random spot between parent_a.P and parent_b.P
    crossingPoint = Math.random();
    child.PID.Ki = parent_a.PID.Ki * crossingPoint + parent_b.PID.Ki * (1.0 - crossingPoint);
    crossingPoint = Math.random();
    child.PID.Kd = parent_a.PID.Kd * crossingPoint + parent_b.PID.Kd * (1.0 - crossingPoint);
    return child;
  }
}
