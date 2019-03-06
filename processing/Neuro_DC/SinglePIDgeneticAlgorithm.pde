public class SinglePIDgeneticAlgorithm
{
  SinglePIDsimulator[] organism;
  SinglePIDsimulator[] nextGenerationOrganism;
  SinglePIDsimulator best = new SinglePIDsimulator();

  /*static*/  int populationSize; /**ilość osobników w populacji   */
  int generationCounter = 0;

  double bestFit = 0;
  double[] objectParameters;

  double rand;

  double KpRange = 10;
  double KiRange = 10;
  double KdRange = 10;

  long numberOfProbes; /** ilość próbek symulacji   */
  double timeStep;

  public SinglePIDgeneticAlgorithm(long _numberOfProbes, int _pupulationSize, double _timeStep)
  {
    numberOfProbes = _numberOfProbes;
    populationSize = _pupulationSize;
    organism = new SinglePIDsimulator[populationSize];
    nextGenerationOrganism = new SinglePIDsimulator[populationSize];
    timeStep = _timeStep;

    for (int i = 0; i < populationSize; i++)
    {
      organism[i] = new SinglePIDsimulator();
      organism[i].PID.Kp = ((Math.random() * 2.0) - 1.0) * KpRange; //randomize a P value between -KpRange and KpRange
      organism[i].PID.Ki = ((Math.random() * 2.0) - 1.0) * KiRange;
      organism[i].PID.Kd = ((Math.random() * 2.0) - 1.0) * KdRange;
    }
  }

  //Przeprowadzenie jednej generacji aż do momentu powstania nowej
  public void doOneGeneration()
  {
    for (int i = 0; i < populationSize; i++)
    {
      organism[i].Simulate(numberOfProbes, timeStep);
    }
    normalizeFitness();
    nextGeneration();
    generationCounter++;
  }


  //Wyświetla najlepszy wynik operacji numerycznych. 
  public double[] showBest()
  {
    best.Simulate(numberOfProbes, timeStep);
    double[] PID = { best.PID.Kp, best.PID.Ki, best.PID.Kd };
    print(best.PID.Kp, best.PID.Ki, best.PID.Kd);
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
      organism[i] = nextGenerationOrganism[i];
  }


  //Wybór jednego osobnika z populacji oraz delikatna modyfikacja jego nastaw
  void pickTweak(int i)
  {
    SinglePIDsimulator parent = new SinglePIDsimulator();
    int x;
    boolean picked;

    if (Math.random() > 0.01)
    {
      picked = false;
      do
      {
        x = (int)(Math.random() * populationSize); 
        if (Math.random() <= organism[x].fitness)
        {
          parent = organism[x];
          picked = true;
        }
      } 
      while (!picked);
    } else
    {
      parent = best;
    }
    nextGenerationOrganism[i] = tweak(parent);
  }


  //Wybieranie dwóch osobników z populacji oraz krzyżowanie ich.
  void pickAndCross(int i)
  {
    SinglePIDsimulator parentA = new SinglePIDsimulator();
    int a;
    SinglePIDsimulator parentB = new SinglePIDsimulator();
    int b;
    boolean picked;

    picked = false;
    do
    {
      a = (int)(Math.random() * populationSize);
      if (Math.random() <= organism[a].fitness)
      {
        parentA = organism[a];
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
        if (a != b && (Math.random() <= organism[b].fitness))
        {
          parentB = organism[b];
          picked = true;
        }
      } 
      while (!picked);
    } else
    {
      parentB = best; // 1% chance of picking "best" as a pair to cross with
    }
    nextGenerationOrganism[i] = cross(parentA, parentB);
  }

  //Normalizacja wartości fitness wszystkich osobników tak aby były wartościami od 0 do 1
  void normalizeFitness()
  {
    double maxFit = 0;
    double minFit;

    //Oszacowanie maksymalnej wartości fit.
    for (int i = 0; i < populationSize; i++)
    {
      if (organism[i].fitness > maxFit)
      {
        maxFit = organism[i].fitness;
        if (maxFit > bestFit)
        {
          bestFit = maxFit;
          best = organism[i];
        }
      }
    }
    //Oszacowanie minimalnej wartości fit.
    minFit = maxFit;
    for (int i = 0; i < populationSize; i++)
    {
      minFit = organism[i].fitness < minFit ? organism[i].fitness : minFit;
    }

    if (maxFit != 0)
      for (int i = 0; i < populationSize; i++)
      {
        organism[i].fitness -= minFit;
        organism[i].fitness /= (maxFit - minFit);
      }
  }


  //Funkcja tworząca nowy losowy organizm
  void mutatant(int i)
  {
    SinglePIDsimulator child = new SinglePIDsimulator();
    child.PID.Kp = ((Math.random() * 2.0) - 1.0) * KpRange; //randomize a P value between -KpRange and KpRange
    child.PID.Ki = ((Math.random() * 2.0) - 1.0) * KiRange;
    child.PID.Kd = ((Math.random() * 2.0) - 1.0) * KdRange;
    if (Math.random() > 0.01) 
    {
      nextGenerationOrganism[i] = child;
    } else 
    {
      nextGenerationOrganism[i] = best; // 1% chance of picking "best" as a mutant
    }
  }


  //Funkcja delikatnie modyfikująca jeden organizm
  SinglePIDsimulator tweak(SinglePIDsimulator parent) 
  {
    SinglePIDsimulator child = new SinglePIDsimulator();
    child.PID.Kp = parent.PID.Kp + (Math.random() * 2.0) - 1.0; // value of P +- random between 0 and 1
    child.PID.Ki = parent.PID.Ki + (Math.random() * 2.0) - 1.0;
    child.PID.Kd = parent.PID.Kd + (Math.random() * 2.0) - 1.0;
    return child;
  }


  //  Funkcja krzyrzująca dwa organizmy
  SinglePIDsimulator cross(SinglePIDsimulator parentA, SinglePIDsimulator parentB)
  {
    SinglePIDsimulator child = new SinglePIDsimulator();
    double crossingPoint = Math.random();
    child.PID.Kp = parentA.PID.Kp * crossingPoint + parentB.PID.Kp * (1.0 - crossingPoint); // picking a new P value in random spot between parentA.P and parentB.P
    crossingPoint = Math.random();
    child.PID.Ki = parentA.PID.Ki * crossingPoint + parentB.PID.Ki * (1.0 - crossingPoint);
    crossingPoint = Math.random();
    child.PID.Kd = parentA.PID.Kd * crossingPoint + parentB.PID.Kd * (1.0 - crossingPoint);
    return child;
  }

  public void SetAbsoluteErrorIntegral()
  {
    for (int i = 0; i < populationSize; i++)
    {
      organism[i].SetAbsoluteErrorIntegral();
    }
  }

  public void SetSquareErrorIntegral()
  {
    for (int i = 0; i < populationSize; i++)
    {
      organism[i].SetSquareErrorIntegral();
    }
  }
}
