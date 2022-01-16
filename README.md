# Resize Shape
This adds the ability to resize (or scale) a shape (currently only `CollisionShape`s but this could be easily expanded to similar things) that actually changes the size of the shape.  
This is _not_ done at runtime (though the code could potentially be copied to do the action at runtime), but rather this plugin adds a button to the editor to allow you to decide how to scale the points that make it up.  
Currently this ignores objects for which scaling is not obvious to implement, such as cylinders, capsules, planes, heightmaps, and a few more.  
This extension could be made more general and useful, especially if the resize option was made specific to shapes (since there's no sensible way to resize a capsuleshape by x,y,z without converting into a different shape kind), but it currently works for what I needed.
  
This was primarily made because Godot's current code for generating a `CollisionShape` for a `MeshInstance` inherits the scaling of the `MeshInstance`, and since scaling a `CollisionShape` is inadvisable, this is irritating. Changing the scaling back would just mean it is too large, and so there was no easy way to convert that Convex polygon shape to be smaller. This extension simply does that.  
It essentially just multiplies all the points (or extents in the case of a box shape) by the x,y,z scaling factors.  
  
This currently isn't on the asset library. In part because it could/should be improved before that, but also it being somewhat tedious to put it on there. The code is simple enough that you can simply code the addons/resize_shape/ folder into your addons folder. Enable it in the Project Settings -> Plugins tab, and ta-da, it should work.
