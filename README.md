# Triplanar

Triplanar mapping for Unity to achieve texturing models without UV. To simulate ground I'm using two textures, one for the "flat horizontal" surface of the model and the other one for the "sides". 
To blend the normals I'm using RNM blending.
Thanks to Ben Golus for his [medium](medium.com/@bgolus/normal-mapping-for-a-triplanar-shader-10bf39dca05a) in-depth article.

![triplanargif](https://user-images.githubusercontent.com/36453077/36275275-aedca3f4-128a-11e8-96a7-694ddf798862.gif)

----
# Raymarching

This shader collection contains a small scene with Raymarching. It's affected by unity's lighting (not shadowing yet) and object position/rotation/scale. 
Thanks to Iñigo Quilez for all his articles about raymarching and his ShaderToy examples.


![Raymarching](https://user-images.githubusercontent.com/36453077/36275520-5d86f422-128b-11e8-8cb2-2305b5f067df.gif)
----
Assets sources:
* https://www.textures.com/download/3dscans0087/128331?q=snow
* https://freepbr.com/materials/mossy-ground-1-pbr-material/
* https://freepbr.com/materials/slate-rock-2-pbr-material/
* https://free3d.com/3d-model/rock-86533.html
