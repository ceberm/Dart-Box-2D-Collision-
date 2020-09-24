import 'package:box2d_flame/box2d.dart' as Box2D;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/particle_component.dart';


class Box2DAndFlame extends Game {
  Box2D.World _world;

  Box2DAndFlame() : _world = Box2D.World.withGravity(Box2D.Vector2(0, 9.81)) {
    var bodyDef = Box2D.BodyDef();
    bodyDef.type = Box2D.BodyType.DYNAMIC; // The body type.
    bodyDef.position = Box2D.Vector2(100, 100); // The position of the body.
    bodyDef.angle = 0; // The angle of the body.

    var dynamicBody =
        _world.createBody(bodyDef); // Add the bodyDef to the world.

    var boxShape = Box2D.PolygonShape();
    boxShape.setAsBox(10, 10, Box2D.Vector2(10, 20), 0);

    var boxFixtureDef = Box2D.FixtureDef();
    boxFixtureDef.shape = boxShape;
    boxFixtureDef.density = 1;
    dynamicBody.createFixtureFromFixtureDef(boxFixtureDef);

    dynamicBody.setTransform(Box2D.Vector2(150, 80), 3);

    dynamicBody.linearVelocity = Box2D.Vector2(-5, 5);
    dynamicBody.angularVelocity = -3;

    bodyDef.type = Box2D.BodyType.KINEMATIC; // Change the body type to STATIC.
    bodyDef.position =
        Box2D.Vector2(100, 200); // Change the position to be sllightly lower.
    var staticBody =
        _world.createBody(bodyDef); // Once again add the bodyDef to the world.
    staticBody
        .createFixtureFromFixtureDef(boxFixtureDef); // And add our fixture.

        staticBody.angularVelocity = 1;

    bodyDef.type =
         Box2D.BodyType.KINEMATIC; // Now we change the body type to KINEMATIC.
     bodyDef.position =
         Box2D.Vector2(60, 200); // Change the position once again.
     var kinematicBody =
         _world.createBody(bodyDef); // Add the bodyDef to the world.
     kinematicBody
         .createFixtureFromFixtureDef(boxFixtureDef); // And add our fixture.

     kinematicBody.angularVelocity = -0.5;

  }
  @override
  void render(Canvas canvas) {
    _world.forEachBody((body) {
      for (var fixture = body.getFixtureList();
          fixture != null;
          fixture = fixture.getNext()) {
        final color = body.getType() == Box2D.BodyType.STATIC
            ? Colors.red
            : body.getType() == Box2D.BodyType.DYNAMIC
                ? Colors.blue
                : Colors.green;

        final Box2D.Shape shape = fixture.getShape();
        if (shape is Box2D.EdgeShape) {
          canvas.save();
          canvas.translate(body.position.x, body.position.y);
          canvas.drawLine(
            Offset(shape.vertex1.x, shape.vertex1.y),
            Offset(shape.vertex2.x, shape.vertex2.y),
            Paint()..color = color,
          );
          canvas.restore();
        } else if (shape is Box2D.CircleShape) {
          canvas.save();
          canvas.translate(body.position.x, body.position.y);
          canvas.rotate(body.getAngle());
          canvas.drawCircle(
            Offset(shape.p.x, shape.p.y),
            shape.radius,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
          );
          canvas.drawCircle(
            Offset(shape.p.x, shape.p.y),
            shape.radius,
            Paint()..color = color.withAlpha(50),
          );

          canvas.drawLine(
            Offset(shape.p.x, shape.p.y),
            Offset(shape.p.x + shape.radius, shape.p.y),
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
          );
          canvas.restore();
        } else if (shape is Box2D.PolygonShape) {
          final List<Box2D.Vector2> vertices =
              Box2D.Vec2Array().get(shape.count);

          for (int i = 0; i < shape.count; ++i) {
            body.getWorldPointToOut(shape.vertices[i],
                vertices[i]); // Copy world point to our List.
          }

          final List<Offset> points = [];
          for (int i = 0; i < shape.count; i++) {
            points.add(Offset(
                vertices[i].x, vertices[i].y)); // Convert Vertice to Offset.
          }

          final path = Path()
            ..addPolygon(
                points, true); // Create a path based on the points and draw it.

          canvas.save();
          canvas.drawPath(
            path,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
          );
          canvas.drawPath(path, Paint()..color = color.withAlpha(50));
        }
      }
    });
  }

  @override
  void update(double delta) {
    var velocityIterations = 8; // How strongly to correct velocity.
    var positionIterations = 3; // How strongly to correct position.
    _world.stepDt(delta, velocityIterations, positionIterations);
  }
}


void main() => runApp(Box2DAndFlame().widget);
