"use strict";

async function fetchLevel(index) {
  const response = await fetch(`/levels/${index}.json`);
  const data = await response.json();
  return data;
}

function CodeView(props) {
  const { index } = props;
  const [level, setLevel] = React.useState(null);
  const [activeSource, setActiveSource] = React.useState(null);
  const [hints, setHints] = React.useState(false);
  const activeSourceRef = React.useRef();
  activeSourceRef.current = activeSource;

  function breakLines(parent, startLineNum = 1) {
    // Clone nodes in their original order for consistency during changes
    let nodes = [...parent.childNodes];
    let line = [];
    let lineCount = startLineNum;
    for (let i = 0; i < nodes.length; i++) {
      let node = nodes[i];
      line.push(node);
      if (node.nodeType == Node.TEXT_NODE) {
        while (true) {
          let index = node.textContent.indexOf("\n");
          if (index == -1) break;
          node = node.splitText(index + 1);
          wrapLine(line, lineCount);
          lineCount++;
          line = [node];
        }
      } else if (
        node.nodeType == Node.ELEMENT_NODE &&
        node.classList.contains("language-php")
      ) {
        lineCount = breakLines(node, lineCount);
        line = [];
      }
    }
    if (line.length) {
      wrapLine(line, lineCount);
    }
    return lineCount;
  }

  function wrapLine(line, lineNum) {
    let el = document.createElement("span");
    el.classList.add(`line-${lineNum}`);
    line[0].parentNode.insertBefore(el, line[0]);
    line.map(node => {
      el.appendChild(node);
    });
  }

  React.useEffect(() => {
    fetchLevel(index).then(level => {
      setLevel(level);
      setActiveSource(level.Source[0]);
    });
    Prism.hooks.add("complete", () => {
      let parent = document.querySelector("code");
      breakLines(parent);
      activeSourceRef.current.Hints.map(hint => {
        let line = document.querySelector(`.line-${hint.Line}`);
        line.classList.add("hint");
      });
    });
  }, []);

  React.useEffect(() => {
    Prism.highlightAll();
  }, [activeSource]);

  if (!(level && activeSource)) {
    return <div />;
  }

  return (
    <div>
      <div class="bg-prism-bg rounded-t-lg p-4 mt-10 flex flex-row">
        <div class=" flex-grow">
          {Object.entries(level.Source).map(([key, source]) => {
            const active = source.Name == activeSource.Name;
            return (
              <button
                className={`rounded py-1 px-2 mr-2 mb-2 text-sm focus:outline-none ${
                  active
                    ? "bg-gray-600 text-gray-300"
                    : "text-gray-500 hover:bg-gray-700"
                }`}
                onClick={() => {
                  setActiveSource(source);
                }}
              >
                {source.Basename}
              </button>
            );
          })}
        </div>
      </div>
      <pre class="rounded-b-lg">
        <code className={"language-" + activeSource.Language}>
          {activeSource.Code}
        </code>
      </pre>
    </div>
  );
}
