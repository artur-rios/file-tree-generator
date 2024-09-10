import './app.scss';

import { Header } from '../header/Header';
import { Editor } from '../editor/Editor';
import { Footer } from '../footer/Footer';

export function App() {
  return (
    <main>
      <Header />
      <Editor />
      <Footer />
    </main>
  );
}
