using Unity.Mathematics;
using UnityEngine;

public class Coin : Pickup //使用pickup這個script
{
    [SerializeField] int coinValue = 100;

    ScoreManager scoreManager;

    public void Init(ScoreManager scoreManager)
    {
        this.scoreManager = scoreManager;
    }

    protected override void OnPickup()
    {
        scoreManager.IncreaseScore(coinValue);

    }
}
