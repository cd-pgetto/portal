import { Controller } from "@hotwired/stimulus";
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";

// Connects to data-controller="threejs"
export default class extends Controller {
  static values = { modelUrls: Array };

  initialize() {
    console.log("THREE JS: initializing...");

    this.scene = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(
      75,
      window.innerWidth / window.innerHeight,
      0.1,
      1000,
    );

    this.renderer = new THREE.WebGLRenderer();
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(this.renderer.domElement);

    this.camera.position.set(0, 20, 85);
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);

    this.scene.background = new THREE.Color(0x1f2937);

    this.pointLight1 = new THREE.PointLight(0xffffff);
    this.pointLight1.position.set(100, 25, 200);
    this.pointLight2 = new THREE.PointLight(0xffffff);
    this.pointLight2.position.set(-100, 25, 200);
    this.scene.add(this.pointLight1, this.pointLight2);

    this.gridHelper = new THREE.GridHelper(200, 200);
    this.scene.add(this.gridHelper);
  }

  connect() {
    console.log("THREE JS: connecting....");

    const loader = new GLTFLoader();
    const modelUrls = this.modelUrlsValue;

    modelUrls.forEach((modelUrl) => {
      loader.load(
        modelUrl,
        (gltf) => {
          this.scene.add(gltf.scene);
        },
        (xhr) => {
          console.log((100 * xhr.loaded) / xhr.total + "% loaded");
        },
        (error) => {
          console.error("GLTFLoader error: ", error);
        },
      );
    });

    this.animate();
  }

  animate() {
    requestAnimationFrame(this.animate.bind(this));
    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }
}
