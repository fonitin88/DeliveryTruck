using Unity.Cinemachine;
using UnityEngine;

public class Rock : MonoBehaviour
{
   [SerializeField] ParticleSystem collisionParticleSystem;
   [SerializeField] AudioSource rockSFX;
   [SerializeField] float shakeModifer = 5f;
   [SerializeField] float collisionCooldown = 1f;//cooldown

   CinemachineImpulseSource cinemachineImpulseSource;

   float collisionTimer = 0f;//cooldown

   void Awake()
   {
      cinemachineImpulseSource = GetComponent<CinemachineImpulseSource>();
   }
   void Update()
   {
      collisionTimer += Time.deltaTime;//cooldown
   }

   void OnCollisionEnter(Collision other)
   {
      if (collisionTimer < collisionCooldown) return;//cooldown
      FireImpulse();
      CollisionFX(other);
      collisionTimer = 0f;//cooldown
   }

   void FireImpulse()
   {
      float distance = Vector3.Distance(transform.position, Camera.main.transform.position);
      float shakeIntensity = (1f / distance) * shakeModifer;
      shakeIntensity = Mathf.Min(shakeIntensity, 1f);
      cinemachineImpulseSource.GenerateImpulse(shakeIntensity);
   }

   void CollisionFX(Collision other)
   {
      ContactPoint contactPoint = other.contacts[0];
      collisionParticleSystem.transform.position = contactPoint.point;
      collisionParticleSystem.Play();
      rockSFX.Play();
   }
}
