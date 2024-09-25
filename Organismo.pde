class Organismo {
  PVector posicao;
  PVector velocidade;
  float[] dna;
  float vida;    // Indica a aptidão (quanto mais saúde, melhor)
  float velocidadeMax;
  float percepcao; // Distância máxima para detectar recursos
  float tamanho;
  int sexo;  //1 ---> homem  0---> mulher
  int tempoDesdeNascimento;  // Para controlar o tempo desde o nascimento
  
  Organismo(PVector posicao, float[] dna) {
    this.posicao = posicao.copy();
    this.dna = dna;
    this.vida = 100;
    this.tempoDesdeNascimento = 0; // recém-nascido
    
    // Fenótipo derivado do genótipo (DNA)
    this.velocidadeMax = map(dna[0], 0, 1, 2, 5);
    this.percepcao = map(dna[1], 0, 1, 50, 200);
    this.tamanho = map(dna[2], 0, 1, 4, 8);
    this.velocidade = PVector.random2D();
    
    if ((int)(this.tamanho + this.velocidadeMax + this.percepcao) % 2 == 0) {
      this.sexo = 1; // homem
    } else {
      this.sexo = 0; // mulher
    }
  }
  
  void atualiza() {
    // Movimento simples
    posicao.add(velocidade);
    // Consume energia ao se mover
    vida -= velocidadeMax / 10.0;
    tempoDesdeNascimento++; // Incrementa o tempo de vida
    
    // Limites da tela
    if (posicao.x > width) posicao.x = 0;
    if (posicao.x < 0) posicao.x = width;
    if (posicao.y > height) posicao.y = 0;
    if (posicao.y < 0) posicao.y = height;
  }
  
  void procuraComida() {
    PVector maisProximo = null;
    float dist = Float.MAX_VALUE;
    
    for (PVector r : comida) {
      float d = PVector.dist(posicao, r);
      if (d < dist && d < percepcao) {
        dist = d;
        maisProximo = r;
      }
    }
    
    if (maisProximo != null) {
      PVector desejado = PVector.sub(maisProximo, posicao);
      desejado.setMag(velocidadeMax);
      
      PVector direcao = PVector.sub(desejado, velocidade);
      velocidade.add(direcao);
      
      // Se alcançar o recurso, consome-o
      if (dist < tamanho) {
        vida += 20;
        comida.remove(maisProximo);
      }
    }
  }
  
  Organismo procuracompanheiro() {
    Organismo maisProximo = null;
    float dist = Float.MAX_VALUE;
    
    for (Organismo r : populacao) {
      float d = PVector.dist(posicao, r.posicao);
      
      if (d < dist && d < 29 && sexo != r.sexo) {
        dist = d;
        maisProximo = r;
      }
    }
    
    return maisProximo;
  }
  
  Organismo reproduzir(Organismo companheiro) {
    // Reproduz com uma probabilidade baseada na saúde
    if (random(1) < 0.005 && vida > 30 && companheiro.vida > 30) {
      float[] novoDna = new float[3];
      for (int i = 0; i < 3; i++) {
        int gary = (int)random(0, 2);
        novoDna[i] = (gary == 0) ? dna[i] : companheiro.dna[i];
      }
      
      // mutacao
      for (int k = 0; k < novoDna.length; k++) {
        if (random(1) < 0.001) novoDna[k] = constrain(novoDna[k] + random(-0.1, 0.1), 0, 1);
      }
      
      vida -= 10;
      println("Novo organismo nascido! DNA: " + novoDna[0] + ", " + novoDna[1] + ", " + novoDna[2]);
      return new Organismo(posicao, novoDna);
    } else {
      return null;
    }
  }
  
  boolean morreu() {
    return vida <= 0;
  }
  
  void mostra() {
    stroke(0);
    colorMode(HSB, 360, 100, 100);
    
    // Se recém-nascido, aumenta o tamanho por um tempo limitado
    if (tempoDesdeNascimento < 100) {  // Dura 100 frames
      float tamanhoAumentado = tamanho * 1.5;
      fill(cor(map(velocidadeMax, 2, 5, 0, 100)));
      ellipse(posicao.x, posicao.y, tamanhoAumentado, tamanhoAumentado);
    } else {
      fill(cor(map(velocidadeMax, 2, 5, 0, 100)));
      ellipse(posicao.x, posicao.y, tamanho, tamanho);
    }
    
    colorMode(RGB, 255, 255, 255);
  }
  
  color cor(float valor) {
    valor = constrain(valor, 0, 100);
    float matiz = map(valor, 0, 100, 0, 120);
    return color(matiz, 100, 100);
  }
}
